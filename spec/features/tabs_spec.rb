require 'rails_helper'

describe 'Tab Pages' do
  {
    exhibits: Exhibit.all,
    collections: Collection.all
  }.each do |top, all|
    all.each do |tabbed|
      describe tabbed.title do
        "/#{top}/#{tabbed.path}".tap do |target|
          if target =~ /boston-tv-news|american-archive-of-public-broadcasting|stock-sales|alistair-cooke/
            it "doesn't redirect special #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).to eq(target)
            end
          else
            it "redirects #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).not_to eq(target)
            end
          end
          it 'Gives 404 for bad tab' do
            expect { visit target + '/bad' }.to raise_error(ActionController::RoutingError) 
          end
        end
        (tabbed.tabs.keys - %w(intro extra)).each do |path|
          "/#{top}/#{tabbed.path}/#{path}".tap do |target|
            it "loads #{target}" do
              visit target
              expect(page.status_code).to eq(200)
              expect(current_path).to eq(target)
            end
          end
        end
      end
    end
  end

  %w(exhibit collection).each do |base|
    it "Gives 404 for bad #{base}" do
      expect { visit "/#{base}/bad" }.to raise_error(ActionController::RoutingError)
    end
  end
end
