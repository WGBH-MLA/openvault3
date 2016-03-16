class Tabbed < Cmless
  attr_reader :title_html
  attr_reader :head_html
  attr_reader :body_html

  def img_src
    Nokogiri::HTML(head_html).xpath('//img/@src').first.tap do |src|
      return src.text
    end
  rescue
    raise "Problem with #{title}: #{$ERROR_INFO}"
  end

  Tab = Struct.new(:title, :content)
  
  def tabs
    @tabs ||= begin
      doc = Nokogiri::HTML(body_html)
      Hash[
        doc.xpath('//h2').map do |tab_el|
          tab_title = tab_el.text
          tab_html = Cmless.extract_html(doc, tab_title)
          [
            Tabbed.norm(tab_title),
            Tab.new(
              tab_title,
              begin
                Tabbed.expand_links(tab_html)
              rescue NotACatalogLink
                tab_html
              end
            )
          ]
        end
      ]
    end
  end

  def tab_path
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

    TabbedCell = Struct.new(:id, :title, :thumbnail_src)

    ONE_OF_N = /\s*\[(Part 1 of \d+|1)\]/i
    N_OF_N =   /\s*\[(Part \d+ of \d+|\d+)\]/i

    def expand_links(html)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      a_tags = doc.css('a')
      fail NotACatalogLink.new if a_tags.empty? || a_tags.none? { |a| a['href'] && a['href'].match(/\/catalog\?/) }
      a_tags.map do |a|
        fail("Expected catalog url, not #{a['href']}") unless a['href'].match(/\/catalog\?/)
        query = CGI.parse(URI(a['href']).query)
        fail("Expected only one search param, not #{query}") unless query.count == 1
        match = query.keys.first.match(/^f\[(\w+)\]\[\]$/)
        fail("Expected f[something][], not #{query.keys.first}") unless match
        q_key = match[1]
        fail("Expected one search, not #{query}") unless query.values.first.count == 1
        q_val = query.values.first[0]

        # TODO: figure out how to reuse the blacklight, instead of wrapping our own.
        solr_docs = RSolr.connect(url: 'http://localhost:8983/solr/')
                    .get('select', params: {
                           'q' => "#{q_key}:#{q_val}",
                           'fl' => 'id,short_title,thumbnail_src',
                           'sort' => 'short_title asc',
                           'rows' => '1000' # Solr default is 10.
                         })['response']['docs']
        solr_docs.reject do |solr_doc|
          solr_doc['short_title'].match(N_OF_N) && !solr_doc['short_title'].match(ONE_OF_N)
          # Details pages will provide navigation between parts.
        end.map do |solr_doc|
          TabbedCell.new(
            solr_doc['id'],
            solr_doc['short_title']
              .gsub(N_OF_N, ''),
            solr_doc['thumbnail_src']
          )
        end
      end.flatten
    end
  end

  class NotACatalogLink < StandardError
  end
end
