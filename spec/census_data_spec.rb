require 'spec_helper'

describe 'Census data workflow' do

  let(:json) { File.read(File.join(File.dirname(__FILE__), '../conf/census_data.json')) }
  let(:config) { YAML.load(File.read(File.join(File.dirname(__FILE__), '../conf/workflow.yaml'))) }

  describe "Census Data JSON" do

    it 'should be valid json' do
      data = JSON.parse(json)
      data.should_not be_nil
    end

    it 'should have the right number of states' do
      data = JSON.parse(json)
      data['data']['states'].count.should be_equal(52)
    end

    it 'should have the right number of tables' do
      data = JSON.parse(json)
      data['data']['tables'].count.should be_equal(331)
    end
  end

  describe "Census Data URL" do

    it 'should create a valid uri for each data file' do
      uri_template = config['census_data_url']
      data = JSON.parse(json)
      data['data']['states'].each do |state|
        data['data']['tables'].each do |table|
          uri = uri_template.gsub('SS', state['fips']).gsub('TT', table['code']).gsub('LLL', data['data']['summaryCode']['code'])
          puts "#{uri}"
          url = URI.parse(uri)
          url.should be_an_instance_of(URI::HTTP)
        end
      end
    end

  end

  describe ProcessCensusData do

    let!(:census_data_config) { File.join(File.dirname(__FILE__), '../conf/census_data.json')}
    let(:process) { process = ProcessCensusData.new(config['download_dir'], config['census_data_url'], census_data_config) }
    let(:url) {'http://censusdata.ire.org/01/all_160_in_01.P1.csv'}

    it 'should return a new instance' do

      process.should be_an_instance_of(ProcessCensusData)

    end

    it 'should have the download_dir property set' do

      process.download_dir.should_not be_nil

    end

    it 'should have the census_data_url property set' do

      process.census_data_url.should_not be_nil

    end

    it 'should have the census_data_config property set' do

      process.census_data_config.should_not be_nil

    end

    it 'should parse the JSON in the census_data_config file' do

      json = process.parse_census_data_config
      json.should be_an_instance_of(Hash)

    end

    it 'should return an array of urls when create_urls is called' do

      urls = process.create_urls
      urls.should_not be_nil
      urls.count.should be > 0

    end

    it 'should return some string data when fetch_data is called' do

      data = process.fetch_data(url)
      data.should_not be_nil
      data.should be_an_instance_of(String)

    end

    it 'should write a file when write_data_file is called' do

      uri = URI.parse(url)
      data_file = File.join(config['download_dir'], File.basename(uri.path))
      process.write_data_file(data_file, "Sample data written at #{Time.now.strftime('%d/%m/%Y %H:%M')}\n")
      File.exists?(data_file).should_not be_false

    end

    it 'should not return any errors when process is called' do
        process.process()
    end
  end

  describe CensusData do

    let!(:census_data_config) { File.join(File.dirname(__FILE__), '../conf/census_data.json')}
    let(:url) {'http://censusdata.ire.org/01/all_160_in_01.P1.csv'}

    it 'should return an array of urls when create_urls is called' do

      urls = CensusData.create_urls(config['census_data_url'], census_data_config)
      urls.count.should be > 0

    end

    it 'should return a hash when fetch_data is called' do

      data = CensusData.fetch_data(url)
      data.should_not be nil
      data.should be_an_instance_of(Hash)

    end

    it 'should write a file when write_data_file is called' do

      data = { :filename => 'test.csv', :data => "Sample data written at #{Time.now.strftime('%d/%m/%Y %H:%M')}\n" }
      CensusData.write_data_file(config['download_dir'], data)

    end

  end

end

