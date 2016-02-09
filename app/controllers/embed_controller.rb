class EmbedController < CatalogController
  layout 'plain'

  # Right now, outside sites won't be able to use iframes to transclude our content.
  # Uncomment this to make that possible.
  #
  #  def show
  #    super
  #    response.headers.delete('X-Frame-Options')
  #  end
end
