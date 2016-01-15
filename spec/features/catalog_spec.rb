require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Catalog' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end
  
  it 'at least loads the index page' do
    visit '/catalog'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml()
  end
  
  it 'at least loads a details page' do
    visit '/catalog/V_5FDB1545443B427888C90E7B15F3783A'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml()
  end
end