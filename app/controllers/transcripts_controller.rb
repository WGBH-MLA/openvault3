class TranscriptsController < ApplicationController
  include Blacklight::Catalog
    
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
        render text: curl.body_str
      end
    end
  end
  
end
