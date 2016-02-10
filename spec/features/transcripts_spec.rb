require 'rails_helper'
require_relative '../../scripts/lib/pb_core_ingester'
require_relative '../support/validation_helper'

describe 'Transcripts' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  it 'at least loads a details page' do
    visit '/transcripts/A_00000000_MOCK'
    expect(page.status_code).to eq(200)
    expect(page.body).to eq(File.read(Rails.root+'spec/fixtures/transcript/mock-transcript.html'))
  end
end
