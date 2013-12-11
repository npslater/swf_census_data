require 'json'

module CensusData

  def CensusData.create_urls(census_data_url, census_data_config)
    urls = []
    data_config = JSON.parse(File.read(census_data_config))
    data_config['data']['states'].each do |state|
      data_config['data']['tables'].each do |table|
        url = census_data_url.gsub('SS', state['fips']).gsub('TT', table['code']).gsub('LLL', data_config['data']['summaryCode']['code'])
        urls << url
      end
    end
    urls
  end

  def CensusData.fetch_data(url)
    uri = URI.parse(url)
    data = { :filename => File.basename(uri.path), :data => nil }
    Net::HTTP.start(uri.host) do |http|
      resp = http.request_get(uri.path)
      data[:data] = resp.body
    end
    data
  end

  def CensusData.write_data_file(path, data = {})
    begin
      file = File.open(File.join(path, data[:filename]), 'w+')
      file.write(data[:data])
    ensure
      file.close unless file == nil
    end
  end
end