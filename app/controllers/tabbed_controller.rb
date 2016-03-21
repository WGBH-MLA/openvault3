class TabbedController < ApplicationController
  def index
    @all = tab_class.all
  end

  def show
    @item = tab_class.find_by_path(params[:id])
    @page_title = @item.title

    if params[:tab] || @item.tab_path == params[:id] # ie, there is no tab
      fail ActiveRecord::RecordNotFound unless @item.tabs[params[:tab]]
    else
      redirect_to('/' + params[:controller] + '/' + @item.tab_path)
    end
  end
end
