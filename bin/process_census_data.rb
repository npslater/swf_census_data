require 'net/http'
require 'json'

class ProcessCensusData

  attr_accessor :download_dir, :census_data_url, :census_data_config

  def initialize(download_dir, census_data_url, census_data_config)
    @download_dir = download_dir
    @census_data_url = census_data_url
    @census_data_config = census_data_config
  end

  def process

    raise Exception.new('Not implemented yet')

  end

  def parse_census_data_config
    JSON.parse(File.read(@census_data_config))
  end

  def create_urls()
    urls = []
    data_config = parse_census_data_config
    data_config['data']['states'].each do |state|
      data_config['data']['tables'].each do |table|
        url = @census_data_url.gsub('SS', state['fips']).gsub('TT', table['code']).gsub('LLL', data_config['data']['summaryCode']['code'])
        urls << url
      end
    end
    urls
  end

  def fetch_data(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host) do |http|
      resp = http.request_get(uri.path)
      resp.body
    end
  end

  def write_data_file(path, data)
    begin
      file = File.open(path, 'w+')
      file.write(data)
    ensure
      file.close unless file == nil
    end
  end

end