require 'aws-sdk'
require 'optparse'
require 'pp'

class CleanUp

  attr_accessor :config

  def initialize(args)
    @options = parse_args(args)
  end

  def parse_args(args)
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: clean_up.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"
      opts.on('-c', '--config CONFIG', 'Specify the path to the config file') do | config |
        options[:config] = config
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    parser.parse!(args)
    mandatory = [:config]
    missing = mandatory.select{|param| options[param].nil?}
    if not missing.empty?
      puts "Missing options: #{missing.join(', ')}"
      puts parser
      exit
    end
    options
  end

  def load_config(config_file)
    @config = YAML.load(File.read(config_file))
  end

  def clean_up_s3
    s3 = AWS::S3.new
    bucket = s3.buckets[config['s3_bucket']]
    return unless bucket.exists?
    bucket.objects.each do | object |
      object.delete
    end
  end

  def clean_up_files
    Dir.entries(config['download_dir']).each do | entry |
      full_path = File.join(config['download_dir'], entry)
      if File.file?(full_path)
        puts "#{entry}\n"
        File.delete(full_path)
      end
    end

  end

  def clean_up
    load_config(@options[:config])
    clean_up_s3
    clean_up_files
  end
end

cleaner = CleanUp.new(ARGV)
cleaner.clean_up


