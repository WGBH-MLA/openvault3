class Captioner
  VTT_XSLT = Nokogiri::XSLT(File.read(__dir__ + '/xslt/tei_to_vtt.xsl'))

  def self.from_tei(tei_xml)
    tei_doc = Nokogiri::XML(tei_xml)
    ugly_vtt = VTT_XSLT.transform(tei_doc).to_s
               .sub('<?xml version="1.0" encoding="utf-8"?>' + "\n", '').gsub('&gt;', '>') # Bugs in Nokogiri?
               .gsub(/(\D)\s*\n\s*(\D)/, '\1 \2') # remove newlines, and indentation, but only from text blocks
    "WEBVTT FILE\n\n" + ugly_vtt
  end
end
