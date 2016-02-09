require 'rails_helper'

describe ApplicationController, type: :controller do
  describe '.redirect_map' do
    it 'returns an instance of RedirectMap' do
      expect(ApplicationController.redirect_map).to be_a RedirectMap
    end
  end

  describe ':before_action hook' do
    controller(ApplicationController) do
      # mock action for the mock route
      def mock_action; end
    end

    before do
      # create a mock route
      routes.draw { get 'mock_route' => 'anonymous#mock_action' }
    end

    it 'runs RedirectMap#lookup before every action' do
      expect(subject.class.redirect_map).to receive(:lookup).exactly(1).times
      # Rescue nil here. The lack of a mock_action view template will raise an
      # error, but we don't care. We want to test the :before_action hook.
      begin
        get 'mock_action'
      rescue
        nil
      end
    end
  end
end
