require 'rails_helper'
require_relative '../support/validation_helper'

describe 'Tab Pages' do
  {
    exhibits: Exhibit.all,
    collections: Collection.all
  }.each do |top, all|
    all.each do |tabbed|
      describe tabbed.title do
        "/#{top}/#{tabbed.path}".tap do |target|
          if target =~ /boston-tv-news|american-archive-of-public-broadcasting|stock-sales/
            it "doesn't redirect special #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).to eq(target)
              expect_fuzzy_xml
            end
          else
            it "redirects #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).not_to eq(target)
              expect_fuzzy_xml
            end
          end
        end
        (tabbed.tabs.keys - %w(intro extra)).each do |path|
          "/#{top}/#{tabbed.path}/#{path}".tap do |target|
            it "loads #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).to eq(target)
              expect_fuzzy_xml
            end
          end
        end
      end
    end
  end

  describe 'Bad tab 404' do
    it '404s if tab on no-tab page' do
      base = '/collections/boston-tv-news'
      visit(base)
      expect(page.status_code).to eq(200)
      expect { visit(base + '/nope') }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it '404s if tab on no-tab page' do
      base = '/collections/advocates'
      visit(base)
      expect(page.status_code).to eq(200) # Will have redirected
      expect { visit(base + '/nope') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
