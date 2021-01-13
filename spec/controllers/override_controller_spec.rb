require 'rails_helper'

describe OverrideController do
  describe 'GET :show' do
    context 'with an unknown path' do
      it 'renders the a 404 page, with a 404 status, using the main application layout' do
        expect{ get :show, path: 'unknown/path' }.to raise_error ActionController::RoutingError
      end
    end
  end
end
