class TranscriptsController < ApplicationController
  include Blacklight::Catalog
    
  XSLT = Nokogiri::XSLT(File.read(__dir__+'/../../lib/xslt/tei_to_html.xsl'))
  
  def show
    # TODO: do we need more of the behavior from Blacklight::Catalog?
    @response, @document = fetch(params['id'])
    xml = @document['xml']

    respond_to do |format|
      format.html do
        @pbcore = PBCore.new(xml)
        curl = Curl::Easy.http_get(@pbcore.transcript_src)
        # S3 might do referer checks in the future
        # curl.headers['Referer'] = 'http://openvault.wgbh.org/'
        curl.perform
        tei_doc = Nokogiri::XML(curl.body_str)
        render text: '<html><body>' + XSLT.transform(tei_doc).to_xml + '</body></html>'
        # TODO: Clean this up
        # TODO: caching?
      end
    end
  end
  
end
