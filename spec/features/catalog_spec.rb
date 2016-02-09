require 'rails_helper'
require_relative '../support/validation_helper'
require_relative '../../scripts/lib/pb_core_ingester'

describe 'Catalog' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  it 'loads the index page' do
    visit '/catalog'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
  end

  it 'redirects missing access' do
    visit '/catalog?q='
    expect(page.status_code).to eq(200)
    expect(URI.parse(current_url).query).to eq('f[access][]=Available+Online&q=')
  end

  it 'redirects missing everything' do
    visit '/catalog?'
    expect(page.status_code).to eq(200)
    expect(URI.parse(current_url).query).to eq('f[access][]=Available+Online')
  end

  it 'has a helpful no-results' do
    visit '/catalog?q=asdfasfasdf'
    expect(page.status_code).to eq(200)
    expect(page).to have_content 'Consider using other search terms, removing filters, or searching all records, not just those with media.'
    expect_fuzzy_xml
  end

  it 'also has an unhelpful no-results' do
    visit '/catalog?q=asdfasfasdf&f[access][]=All+Records'
    expect(page.status_code).to eq(200)
    expect(page).to have_content 'Consider using other search terms or removing filters.'
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

  it 'sorts by title ascending, ignoring articles' do
    visit '/catalog?f[access][]=All+Records&q=sort&sort=title+asc'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
    expect(page.all('.info').map(&:text)).to eq([
      '"The" removed: sort 1',
      '"An" REMOVED: SORT 2',
      '"A" removed: sort 3'
    ])
  end

  it 'sorts by title descending, ignoring articles' do
    visit '/catalog?f[access][]=All+Records&q=sort&sort=title+desc'
    expect(page.status_code).to eq(200)
    expect_fuzzy_xml
    expect(page.all('.info').map(&:text)).to eq([
      '"A" removed: sort 3',
      '"An" REMOVED: SORT 2',
      '"The" removed: sort 1'
    ])
  end
end
