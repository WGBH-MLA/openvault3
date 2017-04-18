require 'set'

class SeriesList
  def initialize(series_all = nil, series_online = nil) # Optional params only for tests
    series_all ||= SeriesList.series_facet(false)
    series_online ||= SeriesList.series_facet(true)

    pairs = Hash[series_all.keys.map do |title|
      [
        title,
        {
          online: series_online[title],
          all: series_all[title]
        }
      ]
    end]

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

    def series_facet(online_only)
      solr_params = {
        'facet.field' => 'series_title',
        'facet' => 'true',
        'rows' => '0',
        'f.series_title.facet.limit' => -1
      }
      solr_params['fq'] = 'access:"' + PBCore::ONLINE + '"' if online_only
      # Solr only accepts double-quote here.

      Hash[
        RSolr.connect(url: "http://localhost:#{ENV['JETTY_PORT']}/solr/")
          .get(
            'select', params: solr_params
          )['facet_counts']['facet_fields']['series_title'].in_groups_of(2)]
    end
  end
end
