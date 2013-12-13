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
      if resp.header[ 'Content-Encoding' ].eql?( 'gzip' ) then
        sio = StringIO.new( resp.body )
        gz = Zlib::GzipReader.new( sio )
        data[:data] = gz.read
      else
        data[:data] = resp.body
      end
    end
    data
  end

  def CensusData.write_data_file(path, data = {})
    raise Exception.new("filename cannot be null") unless data[:filename]
    data[:data] = nil unless data[:data]
    begin
      full_path = File.join(path, data[:filename])
      file = File.open(full_path, 'w+')
      file.write(data[:data])
      full_path
    ensure
      file.close unless file == nil
    end
  end
end