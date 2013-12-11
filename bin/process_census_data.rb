require 'net/http'
require 'json'
require_relative '../lib/census_data'

class ProcessCensusData

  attr_accessor :download_dir, :census_data_url, :census_data_config, :download_limit

  def initialize(download_dir, census_data_url, census_data_config, download_limit)
    @download_dir = download_dir
    @census_data_url = census_data_url
    @census_data_config = census_data_config
    @download_limit = download_limit
  end

  def process
  urls = @download_limit != nil ? CensusData.create_urls(@census_data_url, @census_data_config)[0..(@download_limit-1)] : CensusData.create_urls(@census_data_url, @census_data_config)
  urls.each do | url |
    data = CensusData.fetch_data(url)
    CensusData.write_data_file(@download_dir, data)
  end

  end

end