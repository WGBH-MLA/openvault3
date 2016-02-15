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
    visit '/collections/advocates-advocates/full-program-video'
    expect(page.status_code).to eq(200)
    expect(page).to have_text('The Advocates')
    expect_fuzzy_xml
  end
  it 'has short titles' do
    visit '/collections/vietnam-the-vietnam-collection/interviews'
    expect(page.html).to match(/>\s*same program; different asset title\s*</)
    expect(page.html).to match(/>\s*Interview with XYZ is kept\s*/)
  end
end
