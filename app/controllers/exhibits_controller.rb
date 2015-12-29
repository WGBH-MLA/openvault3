class ExhibitsController < ApplicationController
  def index
    @exhibits = Exhibit.all
  end
  
  def show
    @exhibit = Exhibit.find_by_path(params[:id])
    @page_title = @exhibit.title
    @tabs = @exhibit.tabs
  end
end