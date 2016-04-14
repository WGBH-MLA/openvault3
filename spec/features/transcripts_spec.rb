require 'rails_helper'
require_relative '../../scripts/lib/pb_core_ingester'
require_relative '../support/validation_helper'

describe 'Transcripts' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  it 'proxies the XML' do
    visit '/transcripts/A_00000000_MOCK.xml'
    expect(page.status_code).to eq(200)
    expect(page.body).to eq(File.read(Rails.root + 'spec/fixtures/transcript/mock-transcript.xml'))
  end

  it 'generates HTML' do
    visit '/transcripts/A_00000000_MOCK'
    expect(page.status_code).to eq(200)
    expect(page.body).to match(File.read(Rails.root + 'spec/fixtures/transcript/mock-transcript.html'))
  end
  
  it 'generates WebVTT' do
    visit '/transcripts/A_00000000_MOCK.vtt'
    expect(page.status_code).to eq(200)
    expect(page.body).to match(File.read(Rails.root + 'spec/fixtures/transcript/mock-transcript.vtt'))
  end
end
