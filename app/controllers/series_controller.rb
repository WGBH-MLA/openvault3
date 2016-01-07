class SeriesController < ApplicationController
  def index
    series = Hash[
      RSolr.connect(url: 'http://localhost:8983/solr/')
           .get('select', params: {
               'facet.field' => 'series_title',
               'facet' => 'true',
               'rows' => '0',
               'f.series_title.facet.limit' => -1
             }
           )['facet_counts']['facet_fields']['series_title'].in_groups_of(2)]
    @series_by_first_letter = series.each_pair.group_by{|pair| pair.first[0].upcase }
  end
end