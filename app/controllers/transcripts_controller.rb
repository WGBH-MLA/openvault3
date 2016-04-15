class TranscriptsController < ApplicationController
  include Blacklight::Catalog

  layout 'transcript'

  caches_page :show
  def show
    @response, @document = fetch(params['id'])
    curl = Curl::Easy.http_get(PBCore.new(@document['xml']).transcript_src)
    curl.headers['Referer'] = 'http://openvault.wgbh.org/'
    curl.perform

    respond_to do |format|
      format.html do
        @transcript_html = Transcripter.from_tei(curl.body_str)
        render
      end
      format.vtt do
        render text: Captioner.from_tei(curl.body_str)
      end
      format.xml do
        render text: curl.body_str
      end
    end
  end
end
