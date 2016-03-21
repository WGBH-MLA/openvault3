require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Special Collections' do
  it 'at least loads the index page' do
    visit '/collections'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('The Advocates')
    expect_fuzzy_xml
  end
  it 'at least loads a details page tab' do
    visit '/collections/advocates/full-program-video'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('The Advocates')
    expect_fuzzy_xml
  end
end
