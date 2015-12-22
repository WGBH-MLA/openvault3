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
        doc.xpath("//h2").map do |h2_el|
          h2_text = h2_el.text
          [self.class.norm(h2_text), Cmless.extract_html(doc, h2_text)]
        end
      ]
    end
  end
  
  class << self
    def norm(s)
      s.downcase.gsub(/\s/, '-')
    end
  end
  
end