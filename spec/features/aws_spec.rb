require 'rails_helper'
require 'curl'

describe 'AWS' do
  URL = 'https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_transcripts/A_00000000_MOCK.xml'

  describe 'good hosts' do
    ['localhost:3000', 'openvault.wgbh.org', 'demo.openvault.wgbh.org'].each do |host|
      it "loads from #{host}" do
        curl = Curl::Easy.http_get(URL)
        curl.headers['Referer'] = "http://#{host}/foo-bar"
        curl.perform
        expect(curl.status).to eq('200 OK')
      end
    end
  end

  describe 'bad hosts' do
    ['localhost:3001', 'XYZ.openvault.wgbh.org', 'random.com'].each do |host|
      it "does not load from #{host}" do
        curl = Curl::Easy.http_get(URL)
        curl.headers['Referer'] = "http://#{host}/foo-bar"
        curl.perform
        expect(curl.status).to eq('403 Forbidden')
      end
    end
  end

  describe 'missing referer' do
    it 'does not load w/o referer' do
      curl = Curl::Easy.http_get(URL)
      curl.perform
      expect(curl.status).to eq('403 Forbidden')
    end
  end
end
