require 'yaml'
require 'pry'


module LegacyUrlRedirects
  @@redirects = YAML.load(File.read(Rails.root.join('config', 'legacy_url_redirects.yml')))

  def redirect_legacy_url
    url = request.fullpath
    redirect_to @@redirects[url] unless url.nil? || @@redirects[url].nil?
  end
end