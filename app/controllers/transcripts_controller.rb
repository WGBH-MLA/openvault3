class TranscriptsController < ApplicationController
  include Blacklight::Catalog
  
  layout 'plain'
    
  XSLT = Nokogiri::XSLT(File.read(__dir__+'/../../lib/xslt/tei_to_html.xsl'))
  
  def show
    @response, @document = fetch(params['id'])
    curl = Curl::Easy.http_get(PBCore.new(@document['xml']).transcript_src)
    # S3 might do referer checks in the future
    # curl.headers['Referer'] = 'http://openvault.wgbh.org/'
    curl.perform
    tei_doc = Nokogiri::XML(curl.body_str)
    @transcript_html = XSLT.transform(tei_doc).to_xml
  end
  
end
