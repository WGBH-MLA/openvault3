class OaiController < ApplicationController
  Record = Struct.new(:id, :date, :pbcore)
  ROWS = 100

  def index
    @verb = params.delete(:verb)
    fail("Unsupported verb: #{@verb}") unless @verb == 'ListRecords'

    @metadata_prefix = params.delete(:metadataPrefix) || 'pbcore'
    fail("Unsupported metadataPrefix: #{@metadata_prefix}") unless @metadata_prefix == 'pbcore'

    resumption_token = params.delete(:resumptionToken) || '0'
    fail("Unsupported resumptionToken: #{resumption_token}") unless resumption_token =~ /^\d*$/
    start = resumption_token.to_i

    unsupported = params.keys - %w(action controller format)
    fail("Unsupported params: #{unsupported}") unless unsupported.empty?

    @response_date = Time.now.strftime('%FT%T')

    @records =
      RSolr.connect(url: 'http://localhost:8983/solr/')
      .get('select', params: {
             'q' => '*:*',
             'fl' => 'id,timestamp,xml',
             'rows' => ROWS,
             'start' => start
           })['response']['docs'].map do |d|
        Record.new(
          d['id'],
          d['timestamp'],
          d['xml'].gsub('<?xml version="1.0" encoding="UTF-8"?>', '').strip)
      end

    @next_resumption_token = # Not ideal: they'll need to go past the end.
      if @records.empty?
        nil
      else
        start + ROWS
      end

    respond_to do |format|
      format.xml do
        render
      end
    end
  end
end
