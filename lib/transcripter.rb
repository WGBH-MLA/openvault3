class Transcripter
  HTML_XSLT = Nokogiri::XSLT(File.read(__dir__ + '/xslt/tei_to_html.xsl'))
  
  def self.from_tei(tei_xml)
    tei_doc = Nokogiri::XML(tei_xml)
    ugly_xml = HTML_XSLT.transform(tei_doc).to_xml
    Nokogiri::XML(ugly_xml) do |config|
      config.options = Nokogiri::XML::ParseOptions::NOBLANKS
    end.to_xml
    .sub('<?xml version="1.0" encoding="utf-8"?>', '')
    .sub('xmlns:xhtml="http://www.w3.org/1999/xhtml"', '')
  end
end
