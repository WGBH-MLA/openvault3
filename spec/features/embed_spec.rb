require 'rails_helper'
require_relative '../../scripts/lib/pb_core_ingester'

describe 'Embed' do
  before(:all) do
    PBCoreIngester.load_fixtures
  end

  it 'shows the audio' do
    visit 'embed/A_00B0C50853C64A71935737EF7A4DA66C'
    expect(page).to have_css('audio')
  end
end
