class Collection < Tabbed
  ROOT = File.expand_path('../views/collections', File.dirname(__FILE__))

  attr_reader :extra
  
end