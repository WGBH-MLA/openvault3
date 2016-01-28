require 'rails_helper'
require_relative '../../scripts/lib/pb_core_ingester'
require_relative '../support/validation_helper'

describe 'Transcripts' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end
  
  it 'at least loads a details page' do
    visit '/transcripts/V_5FDB1545443B427888C90E7B15F3783A'
    expect(page.status_code).to eq(200)
    # TODO: figure out how we want to validate.
    # It's just an html fragment, and right now the validator is checking for a title.
    # expect_fuzzy_xml()
  end
end