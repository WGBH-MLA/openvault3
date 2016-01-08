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
    pairs.each_pair.group_by{ |pair| pair.first[0].upcase }.tap do |grouped|
      @by_first_letter = grouped.keys.sort.map { |letter| [letter, grouped[letter]] }
    end
  end
  attr_reader :by_first_letter
end
