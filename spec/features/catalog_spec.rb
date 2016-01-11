require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Catalog' do
  it 'at least loads the index page' do
    visit '/catalog'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml()
  end
  xit 'at least loads a details page' do
    visit '/catalog/1'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml()
  end
end