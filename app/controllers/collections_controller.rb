class CollectionsController < ApplicationController
  def show
    @collection = Collection.find_by_path(params[:id])
    @page_title = @collection.title
  end
end