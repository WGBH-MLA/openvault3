require 'rails_helper'
require_relative '../support/validation_helper'
require_relative '../../scripts/lib/pb_core_ingester'

describe 'Catalog' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  def expect_count(count)
    case count
    when 0
      expect(page).to have_text('No entries found')
    when 1
      expect(page).to have_text('1 entry found')
    else
      expect(page).to have_text("1 - #{[count, 12].min} of #{count}")
    end
  end

  describe '#index' do
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

    it 'sorts by title ascending, ignoring articles' do
      visit '/catalog?f[access][]=All+Records&q=sort&sort=title+asc'
      expect(page.status_code).to eq(200)
      expect_fuzzy_xml
      expect(page.all('.info').map(&:text)).to eq([
        'An. stays: not an article: sort 0',
        'The removed: sort 1',
        'An REMOVED: SORT 2',
        'A removed: sort 3'
      ])
    end

    it 'sorts by title descending, ignoring articles' do
      visit '/catalog?f[access][]=All+Records&q=sort&sort=title+desc'
      expect(page.status_code).to eq(200)
      expect_fuzzy_xml
      expect(page.all('.info').map(&:text)).to eq([
        'A removed: sort 3',
        'An REMOVED: SORT 2',
        'The removed: sort 1',
        'An. stays: not an article: sort 0'
      ])
    end

    it 'highlights keywords in original context' do
      visit '/catalog?f[access][]=Available+Online&q=evil'
      expect(page.status_code).to eq(200)
      expect_fuzzy_xml
      expect(page.html).to include 'Doctor <em>Evil</em> foo foo foo'
    end

    describe 'support facet ORs' do
      describe 'URL support' do
        # OR is supported on all facets, even if not in the UI.
        assertions = [
          ['media_type', 'Video', 1],
          ['media_type', 'Audio', 1],
          ['media_type', 'Image', 1],
          ['media_type', 'Video OR Audio', 2],
          ['media_type', 'Audio OR Image', 2],
          ['media_type', 'Image OR Video', 2],
          ['media_type', 'Video OR Audio OR Image', 3],
          ['series_title', 'SERIES', 1],
          ['program_title', 'PROGRAM', 1],
          ['genres', 'GENRE-1', 1],
          ['topics', 'TOPIC-1', 1],
          ['asset_type', 'Original footage', 3]
        ]
        assertions.each do |facet, value, value_count|
          url = '/catalog?' + {
            f: { access: [PBCore::ONLINE],
                 facet => [value] }
          }.to_query
          describe "visiting #{url}" do
            it "has #{value_count} results" do
              visit url
              expect_count(value_count)
            end
          end
        end
      end
    end
  end

  describe '#show' do
    describe 'all fixtures' do
      Dir['spec/fixtures/pbcore/*.xml'].each do |fixture|
        doc = Nokogiri::XML(File.read(fixture))
        doc.remove_namespaces!
        id = doc.xpath('/*/pbcoreIdentifier[@source="Open Vault UID"]').text
        path = "/catalog/#{id}"
        it "loads #{path}" do
          visit path
          expect(page.status_code).to eq(200)
          expect_fuzzy_xml
        end
      end
    end

    it 'Respects line-breaks in source data' do
      visit '/catalog/A_00B0C50853C64A71935737EF7A4DA66C'
      expect(page.html).to match(/<p>Line breaks\s+do not matter, but<\/p><p>empty lines do\.<\/p>/)
    end
  end
end
