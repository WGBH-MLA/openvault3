class TabbedController < ApplicationController
  def index
    @all = tab_class.all
  end

  def show
    @item = tab_class.find_by_path(params[:id])
    @page_title = @item.title
    redirect_to('/' + params[:controller] + '/' + @item.tab_path) unless params[:tab] || @item.tab_path == params[:id]
  end
end
