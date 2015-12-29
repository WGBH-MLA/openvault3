class Exhibit < Tabbed
  ROOT = File.expand_path('../views/exhibits', File.dirname(__FILE__))
  def author
    tabs['author'].gsub(/<[^>]*>/, '')
  end
end