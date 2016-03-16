class Exhibit < Tabbed
  ROOT = File.expand_path('../views/exhibits', File.dirname(__FILE__))
  def author
    @author ||= tabs['author'][:content].gsub(/<[^>]*>/, '')
    # TODO: Use xpath.
  end
end
