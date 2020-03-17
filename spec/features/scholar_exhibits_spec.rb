require 'rails_helper'

describe 'Scholar Exhibits' do
  FRAGMENT = 'Important & Relevant' # Make sure character entities are handled correctly.
  it 'at least loads the index page' do
    visit '/exhibits'
    expect(page.status_code).to eq(200)
    expect(page).to have_text(FRAGMENT)
  end
  it 'at least loads a details page' do
    visit '/exhibits/advocates/article'
    expect(page.status_code).to eq(200)
    expect(page).to have_text(FRAGMENT)
  end
end
