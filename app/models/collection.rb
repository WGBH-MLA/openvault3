require_relative 'tabbed'

class Collection < Tabbed
  ROOT = File.expand_path('../views/collections', File.dirname(__FILE__))
end
