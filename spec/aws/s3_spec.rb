require 'aws-sdk'
require 'json'

describe 'S3', not_on_travis: true do
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
