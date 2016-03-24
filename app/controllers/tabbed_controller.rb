class TabbedController < ApplicationController
  def index
    @all = tab_class.all
  end

  def show
    begin
      @item = tab_class.find_by_path(params[:id])
    rescue IndexError
      raise ActiveRecord::RecordNotFound
    end
    @page_title = @item.title

    if params[:tab]
      fail ActiveRecord::RecordNotFound unless @item.tabs[params[:tab]]
    else
      redirect_to('/' + params[:controller] + '/' + @item.tab_path) if @item.tab_path != params[:id]
    end
  end
end
