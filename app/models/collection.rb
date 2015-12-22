class Collection < Cmless
  ROOT = File.expand_path('../views/collections', File.dirname(__FILE__))
  attr_reader :head_html
  attr_reader :short_html
  attr_reader :medium_html
  attr_reader :long_html
  attr_reader :links_html
  attr_reader :grid_html

  private
  
  def img_src(alt)
    Nokogiri::HTML(head_html).xpath("//img[@alt='#{alt}']/@src").first.tap do |optional|
      if optional
        return optional.text
      else
        return nil
      end
    end
  end
  
  def url_around_img(alt)
    Nokogiri::HTML(head_html).xpath("//img[@alt='#{alt}']/../@href").first.tap do |optional|
      if optional
        return optional.text
      else
        return nil
      end
    end
  end
  
  public
  
  def thumb_src
    @thumb_src ||= img_src('thumb')
  end
  
  def splash_src
    @splash_src ||= img_src('splash')
  end
  
  def logo_src
    @logo_src ||= img_src('logo')
  end
  
  def url
    @url ||= '/collections/' + path
  end
  
  def splash_url
    @splash_url ||= url_around_img('splash')
  end
  
  def grid_items
    @grid_items ||= begin
      Nokogiri::HTML(grid_html).xpath('//li').map do |li|
        texts = li.text.split(/\s*\|\s*/).map(&:strip)
        title = texts.shift
        short_html = texts.join(' | ')
        OpenStruct.new(
          title: title, 
          short_html: short_html, 
          thumb_src: li.xpath('.//img/@src').text,
          url: li.xpath('.//a/@href').text
        )
      end
    end
  end
  
end