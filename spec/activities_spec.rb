require 'spec_helper'

describe Activities do

  let(:config) { YAML.load(File.read(File.join(File.dirname(__FILE__), '../conf/workflow.yaml'))) }
  let(:url) {'http://censusdata.ire.org/01/all_160_in_01.P1.csv'}

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

  it 'should download the data file and write it to disk' do
    Activities.download_dir = config['download_dir']
    activities = Activities.new
    data_file_path = activities.download_data_file(url)
    File.exist?(data_file_path).should be_true

  end

  it 'should copy the data file to an S3 bucket' do

    data = { :filename => 'test.txt', :data => 'Here is some test data'}
    data_file_path = CensusData.write_data_file(config['download_dir'], data)

    Activities.s3_bucket = config['s3_bucket']
    activities = Activities.new
    activities.copy_file_to_s3(data_file_path)

  end
end
