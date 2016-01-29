require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Scholar Exhibits' do
  it 'at least loads the index page' do
    visit '/exhibits'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('The Julia Child of Needlework')
    expect_fuzzy_xml
  end
  it 'at least loads a details page' do
    visit '/exhibits/erica-wilson/article'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('The Julia Child of Needlework')
    expect_fuzzy_xml
  end
end
