class Tabbed < Cmless
  attr_reader :title_html
  attr_reader :head_html
  attr_reader :body_html
  
  def img_src()
    Nokogiri::HTML(head_html).xpath("//img/@src").first.tap do |src|
      return src.text
    end
  rescue
    raise "Problem with #{title}: #{$!}"
  end
  
  def tabs()
    @tabs ||= begin
      doc = Nokogiri::HTML(body_html)
      Hash[
        doc.xpath("//h2").map do |tab_el|
          tab_text = tab_el.text
          [self.class.norm(tab_text), Tabbed.expand_html(Cmless.extract_html(doc, tab_text))]
        end
      ]
    end
  end
  
  def tab_path()
    first_tab = tabs.keys.reject { |k| k == 'intro' || k == 'author' }.first
    # TODO: This is fragile, but I don't want to make the configuration more complicated.
    if first_tab
      path + '/' + first_tab
    else
      path
    end
  end
  
  class << self
    def norm(s)
      s.downcase.gsub(/\W+/, '-')
    end
    
    def expand_html(html)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      doc.css('a').each do |a|
        if (a['href'].match(/\/catalog\?/))
          query = CGI.parse(URI(a['href']).query)
          fail("Expected only one search param, not #{query}") unless query.count == 1
          match = query.keys.first.match(/^f\[(\w+)\]\[\]$/)
          fail("Expected f[something][], not #{query.keys.first}") unless match
          q_key = match[1]
          fail("Expected one search, not #{query}") unless query.values.first.count == 1
          q_val = query.values.first[0]
          
          # TODO: figure out how to reuse the blacklight, instead of wrapping our own.
          docs = RSolr.connect(url: 'http://localhost:8983/solr/')
            .get('select', params: {
              'q' => "#{q_key}:#{q_val}",
              'fl' => 'id,title,thumbnail_src',
              'rows' => '1000'
            })['response']['docs']
          docs.each do |doc|
            a.add_next_sibling( # TODO: this is really view code...
              <<END
              <div class="document col-md-4 col-sm-6">
                <a href="/catalog/#{doc['id']}">
                    <img src="#{doc['thumbnail_src']}">
                    <div class="info">#{doc['title']}</div>
                  </a>
              </div>
END
            )
          end
# Or if we want three text lists:
#          docs.in_groups(3, false).each do |group|
#            div = a.add_previous_sibling('<div class="col-md-3"></div>')[0]
#            group.each do |doc|
#              div.add_child("<a href='/catalog/#{doc['id']}'>#{doc['title']}</a><br/>")
#            end
#          end
          a.remove
        end
      end
      doc.to_html
    end
  end
  
end