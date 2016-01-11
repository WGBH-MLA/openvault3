class SeriesList
  def initialize(pairs = nil)
    pairs ||= Hash[
      RSolr.connect(url: 'http://localhost:8983/solr/')
           .get('select', params: {
               'facet.field' => 'series_title',
               'facet' => 'true',
               'rows' => '0',
               'f.series_title.facet.limit' => -1
             }
           )['facet_counts']['facet_fields']['series_title'].in_groups_of(2)]
         
    pairs.each_pair.group_by do |pair|
      char = SeriesList.strip_article(pair.first)[0].upcase
      case char
      when /[XYZ]/
        'XYZ'
      when /[A-Z]/
        char
      else
        'other'
      end
    end.tap do |grouped|
      @by_first_letter = grouped.keys.sort.map do |letter| 
        [
          letter, 
          grouped[letter].sort_by do |pair|
            SeriesList.strip_article(pair.first.downcase)
          end
        ]
      end
    end
  end
  attr_reader :by_first_letter
  
  class << self
    def strip_article(s)
      s.match(/^\s*((a|an|the)\s+)?(.*)/im)[3]
    end
  end
end
