require 'optparse'
require 'pp'
require_relative '../lib/aws/swf/activities'

class RunWorkflow

  attr_accessor :config

  def initialize(args)
    @options = parse_args(args)
  end

  private

    def parse_args(args)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: run_worker.rb [options]"
        opts.separator ""
        opts.separator "Specific options:"
        opts.on('-w', '--worker WORKER',
                'Specify whether to run the activities or decider worker') do | worker |
          options[:worker] = worker
        end
        opts.on('-c', '--config CONFIG', 'Specify the path to the config file') do | config |
          options[:config] = config
        end
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      parser.parse!(args)
      mandatory = [:worker, :config]
      missing = mandatory.select{|param| options[param].nil?}
      if not missing.empty?
        puts "Missing options: #{missing.join(', ')}"
        puts parser
        exit
      end

      if ['activities', 'decider'].select{|val| options[:worker].eql?(val)}.empty?
        puts 'Workflow must be one of [activities|decider]'
        puts parser
        exit
      end
      options
    end

    def load_config(config_file)
      @config = YAML.load(File.read(config_file))
    end

  public

    def run
      load_config(@options[:config])
      if @options[:worker].eql?('activities')
        fork do
          puts "Starting activity worker #{Activities}"
          Activities.start(config)
        end
      elsif @options[:worker].eql?('decider')
        raise 'Not implemented yet'
      end
    end
end

runner = RunWorkflow.new(ARGV)
runner.run()

