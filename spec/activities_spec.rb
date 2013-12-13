require 'spec_helper'

describe Activities do

  let(:config) { YAML.load(File.read(File.join(File.dirname(__FILE__), '../conf/workflow.yaml'))) }

  it 'should return a default set of options' do

    Activities.options.should_not be_nil
    Activities.options.should be_an_instance_of(Hash)

  end

  it 'should have a getter and setter for the download_dir property' do
    Activities.download_dir = config['download_dir']
    Activities.download_dir.should_not be_nil
    Activities.download_dir.should eql config['download_dir']
  end

  it 'should have a getter and setter for the s3 bucket property' do

    Activities.s3_bucket = config['s3_bucket']
    Activities.s3_bucket.should_not be_nil
    Activities.s3_bucket.should eql config['s3_bucket']

  end

  it 'should set the activity options to the values passed in from the config file' do
    Activities.options = config['activities']
    Activities.options.should == config['activities']
  end

  it 'should throw an exception if activities are initialized before setting options' do
    begin
      Activities.init_activities
      false.should be_true
    rescue
      true.should be_true
    end
  end

  it 'should not throw an exception if activities are initialized after setting options' do
    begin
      Activities.options = config['activities']
      true.should be_true
    rescue
      false.should be_true
    end
  end
end
