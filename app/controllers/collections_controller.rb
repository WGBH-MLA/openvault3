class CollectionsController < ApplicationController
  def index
    @collections = Collection.objects_by_path
  end
  
  def show
    @collection = Collection.find_by_path(params[:id])
    @page_title = @collection.title
    @tabs = @collection.tabs
  end
end