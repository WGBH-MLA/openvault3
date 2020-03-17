require 'rails_helper'

describe 'Homepage' do
  it 'has expected content' do
    visit '/'

    expect(page.status_code).to eq(200)
    expect(page).to have_text('All rights reserved')
  end
end
