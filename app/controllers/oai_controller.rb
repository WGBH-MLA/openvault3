class OaiController < ApplicationController
  Record = Struct.new(:id, :date, :pbcore)

  def index
    @records =
      RSolr.connect(url: 'http://localhost:8983/solr/')
      .get('select', params: {
             'q' => '*:*',
             'fl' => 'id,timestamp,xml',
             'rows' => '100' # Max for sitemaps
           })['response']['docs'].map do |d|
        Record.new(
          d['id'],
          d['timestamp'],
          d['xml'].gsub('<?xml version="1.0" encoding="UTF-8"?>', '').strip)
      end

    @response_date = '2002-06-01T19:20:30Z'
    @metadata_prefix = 'pbcore'

    respond_to do |format|
      format.xml do
        render
      end
    end
  end
end
