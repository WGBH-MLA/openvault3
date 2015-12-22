class Collection < Cmless
  ROOT = File.expand_path('../views/collections', File.dirname(__FILE__))
  attr_reader :title_html
  attr_reader :head_html
  attr_reader :body_html

  def img_src()
    Nokogiri::HTML(head_html).xpath("//img/@src").first.tap do |src|
      return src.text
    end
  end
  
  def tabs()
    @tabs ||= begin
      doc = Nokogiri::HTML(body_html)
      Hash[
        doc.xpath("//h2").map do |tab_el|
          tab_text = tab_el.text
          [self.class.norm(tab_text), Cmless.extract_html(doc, tab_text)]
        end
      ]
    end
  end
  
  def tab_path()
    path + '/' + tabs.first.first
  end
  
  class << self
    def norm(s)
      s.downcase.gsub(/\W+/, '-')
    end
  end
  
end