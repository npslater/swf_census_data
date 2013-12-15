require 'aws/decider'
require_relative 'domain_helper'

class Decider
  extend AWS::Flow::Workflows
  extend DomainHelper

  def Decider.init_decider(config)
    workflow :census_data_workflow do
      {
          :version => config['decider']['version'],
          :execution_start_to_close_timeout => config['decider']['timeout'],
          :default_task_list => config['task_list']
      }
    end
  end

  def Decider.init_activity_client
    activity_client(:activity) {
      {
          :from_class => 'Activities'
      }
    }
  end

  def census_data_workflow(url)
    puts "census_data_workflow: #{url}"
    path = activity.download_data_file(url)
    activity.copy_file_to_s3(path)
  end

  def Decider.start(config)
    Decider.init_decider(config)
    Activities.options = config['activities']
    Activities.init_activities
    Decider.init_activity_client
    Decider.init_domain(config['domain'])
    worker = AWS::Flow::WorkflowWorker.new(Decider.swf.client, Decider.domain, config['task_list'], Decider)
    worker.start
  end
end