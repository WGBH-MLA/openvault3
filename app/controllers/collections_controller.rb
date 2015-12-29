class CollectionsController < ApplicationController
  def index
    @collections = Collection.all
  end
  
  def show
    @collection = Collection.find_by_path(params[:id])
    @page_title = @collection.title
    @tabs = @collection.tabs
  end
end