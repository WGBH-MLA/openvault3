require 'curl'

describe 'AWS' do
  describe 'good hosts' do
    ['localhost:3000', 'openvault.wgbh.org', 'demo.openvault.wgbh.org'].each do |host|
      it "loads from #{host}" do
        curl = Curl::Easy.http_get('https://s3.amazonaws.com/openvault.wgbh.org/special_collections/advocates/advocates.png')
        curl.headers['Referer'] = "http://#{host}/foo-bar"
        curl.perform
        expect(curl.status).to eq('200 OK')
      end
    end
  end

  describe 'bad hosts' do
    ['localhost:3001', 'XYZ.openvault.wgbh.org', 'random.com'].each do |host|
      it "does not load from #{host}" do
        curl = Curl::Easy.http_get('https://s3.amazonaws.com/openvault.wgbh.org/special_collections/advocates/advocates.png')
        curl.headers['Referer'] = "http://#{host}/foo-bar"
        curl.perform
        expect(curl.status).to eq('403 Forbidden')
      end
    end
  end

  describe 'missing referer' do
    it 'does not load w/o referer' do
      curl = Curl::Easy.http_get('https://s3.amazonaws.com/openvault.wgbh.org/special_collections/advocates/advocates.png')
      curl.perform
      expect(curl.status).to eq('403 Forbidden')
    end
  end
end
