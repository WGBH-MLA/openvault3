class TranscriptsController < ApplicationController
  include Blacklight::Catalog

  layout 'transcript'

  HTML_XSLT = Nokogiri::XSLT(File.read(__dir__ + '/../../lib/xslt/tei_to_html.xsl'))
  VTT_XSLT = Nokogiri::XSLT(File.read(__dir__ + '/../../lib/xslt/tei_to_vtt.xsl'))

  caches_page :show
  def show
    @response, @document = fetch(params['id'])
    curl = Curl::Easy.http_get(PBCore.new(@document['xml']).transcript_src)
    curl.headers['Referer'] = 'http://openvault.wgbh.org/'
    curl.perform

    respond_to do |format|
      format.html do
        tei_doc = Nokogiri::XML(curl.body_str)
        ugly_xml = HTML_XSLT.transform(tei_doc).to_xml
        @transcript_html = Nokogiri::XML(ugly_xml) do |config|
          config.options = Nokogiri::XML::ParseOptions::NOBLANKS
        end.to_xml.sub('<?xml version="1.0" encoding="utf-8"?>', '').sub('xmlns:xhtml="http://www.w3.org/1999/xhtml"', '')
        render
      end
      format.vtt do
        tei_doc = Nokogiri::XML(curl.body_str)
        ugly_vtt = VTT_XSLT.transform(tei_doc).to_s.gsub(/^\s*/, '')
        render text: ugly_vtt.sub('<?xml version="1.0" encoding="utf-8"?>'+"\n", '').gsub('&gt;', '>') # Bugs in Nokogiri?
      end
      format.xml do
        render text: curl.body_str
      end
    end
  end
end
