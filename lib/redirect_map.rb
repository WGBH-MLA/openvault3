require 'yaml'
require 'singleton'

class RedirectMap
  include Singleton

  attr_reader :redirects

  def initialize
    @redirects ||= {}
  end

  def load(filename)
    @redirects = YAML.load(File.read(filename))
    fail InvalidRedirectMapFile, "redirect map file \"#{filename}\" must be a YAML file of key-value pairs" unless @redirects.respond_to?(:key?)
  end

  def lookup(url)
    @redirects[url]
  end

  class InvalidRedirectMapFile < StandardError; end
end
