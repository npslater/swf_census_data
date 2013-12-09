require 'json'
require 'net/http'
require 'uri'
require 'yaml'

describe "Census Data JSON" do

  let(:json) { File.read(File.join(File.dirname(__FILE__), '../conf/census_data.json'))}

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

  let(:json) { File.read(File.join(File.dirname(__FILE__), '../conf/census_data.json'))}
  let(:config) { YAML.load(File.read(File.join(File.dirname(__FILE__), '../conf/workflow.yaml')))}

  it 'should create a valid uri for each data file' do
    uri_template = config['census_data_uri']
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

