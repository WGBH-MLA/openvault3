require 'rails_helper'

describe CatalogController do
  describe 'GET :show' do
    context 'with an invalid record id' do
      it 'renders the a 404 page, with a 404 status, using the main application layout' do
        expect { get :show, id: 'invalid-record-id' }.to raise_error ActionController::RoutingError
      end
    end
  end
end
