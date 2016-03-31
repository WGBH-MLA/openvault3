require 'redirect_map'

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Class accessor for an instance of RedirectMap
  def self.redirect_map
    @redirect_map ||= RedirectMap.instance
  end

  if Rails.env != 'test'
    redirect_map.load Rails.root.join('config', 'redirect_map.yml')
  end

  before_action do
    new_url = self.class.redirect_map.lookup(request.fullpath)
    redirect_to new_url unless new_url.nil?
  end

  def render_404
    render file: 'public/404.html', status: :not_found
  end

  rescue_from StandardError, with: :render_404
end
