class EmbedController < CatalogController
  layout 'embed'
  # Right now, outside sites won't be able to use iframes to transclude our content.
  # Uncomment this to make that possible.
  #
  #  def show
  #    super
  #    response.headers.delete('X-Frame-Options')
  #  end

  def card
    xml = RSolr.connect(url: 'http://localhost:8983/solr/')
      .get('select', params: {
            'q' => "id:#{params[:id]}",
            'fl' => 'id,xml',
            'rows' => 1
          })['response']['docs'].first['xml']
    @pbcore = PBCore.new(xml)
  end
end
