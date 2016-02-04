require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Catalog' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  it 'loads the index page' do
    visit '/catalog'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
  end

  it 'loads a full details page' do
    visit '/catalog/A_00000000_MOCK'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
  end

  it 'loads a minimal details page' do
    visit '/catalog/A_00B0C50853C64A71935737EF7A4DA66C'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
  end
end
