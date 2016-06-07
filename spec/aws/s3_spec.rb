require 'aws-sdk'
require 'json'
require 'curl'

describe 'S3' do
  describe 'policy implementation' , not_on_travis: true do
    def to_pretty_json(string_io)
      JSON.pretty_generate(JSON.parse(string_io.string))
    end
    let(:client) { Aws::S3::Client.new(region: 'us-east-1') }
    it 'has expected policy' do
      expect(
        to_pretty_json(client.get_bucket_policy(bucket: 'openvault.wgbh.org').policy)
      ).to eq(File.read(__dir__ + '/../fixtures/aws/bucket-policy.json'))
    end
  end
  describe 'policy effect' do
    it 'allows thumbnail without referer' do
      curl = Curl::Easy.http_get('https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_thumbnails/V_E7B307B7ACAF4A89B41CFD03EF68630B.jpg')
      curl.perform
      expect(curl.status).to eq('200 OK')
    end
    it 'disallows proxies without referer' do
      curl = Curl::Easy.http_get('https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_proxies/A_00000000_MOCK.mp3')
      curl.perform
      expect(curl.status).to eq('403 Forbidden')
    end
  end
end
