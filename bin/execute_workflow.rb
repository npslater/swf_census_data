require 'optparse'
require 'pp'
require_relative '../lib/aws/swf/decider'
require_relative '../lib/census_data'

class ExecuteWorkflow
  attr_accessor :config

  def initialize(args)
    @options = parse_args(args)
  end

  private

  def parse_args(args)
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: execute_workflow.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"
      opts.on('-c', '--config CONFIG', 'Specify the path to the config file') do | config |
        options[:config] = config
      end
      opts.on('-d', '--data-config DATA_CONFIG', 'Specify the path to the census data config file') do | config |
        options[:data_config] = config
      end
      opts.on('-l', '--exec-limit LIMIT', 'Limit the execution of the workflow to LIMIT') do | limit |
        options[:exec_limit] = limit
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    parser.parse!(args)
    mandatory = [:config, :data_config]
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

  public

  def execute
    load_config(@options[:config])

    Decider.init_decider(config)
    Decider.init_domain(config['domain'])
    workflow_client = AWS::Flow.workflow_client(Decider.swf.client, Decider.domain) {
      {
          :from_class => 'Decider'
      }
    }
    urls =  @options[:exec_limit] ?
        CensusData.create_urls(config['census_data_url'], @options[:data_config])[0..@options[:exec_limit].to_i-1] :
        CensusData.create_urls(config['census_data_url'], @options[:data_config])

    urls.each do |url|
      puts "#{url}\n"
      workflow_client.start_execution(url)
    end
  end
end

executor = ExecuteWorkflow.new(ARGV)
executor.execute()