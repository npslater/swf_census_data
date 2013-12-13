require 'aws/decider'
require_relative '../../census_data'
require_relative 'domain_helper'

class Activities
  extend AWS::Flow::Activities
  extend DomainHelper

  @@options = nil

  def Activities.download_dir=(dir)
    @@download_dir = dir
  end

  def Activities.download_dir
    @@download_dir
  end

  def Activities.s3_bucket=(bucket)
    @@s3_bucket = bucket
  end

  def Activities.s3_bucket
    @@s3_bucket
  end
  
  def Activities.options=(opts)
    @@options = opts
  end
  
  def Activities.options
    @@options
  end

  def Activities.init_activities
    raise 'Options must be set before initializing activities' unless @@options

    activity :download_data_file do
      {
          :version => Activities.options['download_data_file']['version'],
          :default_task_schedule_to_start_timeout => Activities.options['download_data_file']['start_timeout'],
          :default_task_start_to_close_timeout => Activities.options['download_data_file']['close_timeout'],
      }
    end

    activity :write_file_to_disk do
      {
          :version => Activities.options['write_file_to_disk']['version'],
          :default_task_schedule_to_start_timeout => Activities.options['write_file_to_disk']['start_timeout'],
          :default_task_start_to_close_timeout => Activities.options['write_file_to_disk']['close_timeout'],
      }
    end

    activity :copy_file_to_s3 do
      {
          :version => Activities.options['copy_file_to_s3']['version'],
          :default_task_schedule_to_start_timeout => Activities.options['copy_file_to_s3']['start_timeout'],
          :default_task_start_to_close_timeout => Activities.options['copy_file_to_s3']['close_timeout'],
      }
    end
  end

  def download_data_file(url)

    CensusData.fetch_data(url)

  end

  def write_file_to_disk(data)

    CensusData.write_data_file(Activities.download_dir, data)

  end

  def copy_file_to_s3(path)

    s3 = AWS::S3::new()
    s3.buckets[Activities.s3_bucket].objects[File.basename(path)].write(:file => path)

  end

  def Activities.start(config)
    fork do
      puts "Starting Activities"
      Activities.download_dir  = config['download_dir']
      Activities.s3_bucket = config['s3_bucket']
      Activities.options = config['activities']
      Activities.init_activities
      Activities.init_domain(config['domain'])
      activity_worker = AWS::Flow::ActivityWorker.new(Activities.swf.client, Activities.domain, config['task_list'], Activities)
      activity_worker.start
    end
  end

  config = YAML.load(File.read(ARGV[0]))
  Activities.start(config)

end