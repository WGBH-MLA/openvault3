class TabbedController < ApplicationController
  def index
    @all = tab_class.all
  end

  def show
    @item = tab_class.find_by_path(params[:id])
    @page_title = @item.title

    if params[:tab]
      raise ActionController::RoutingError.new("Not Found") unless @item.tabs[params[:tab]]
    else
      redirect_to('/' + params[:controller] + '/' + @item.tab_path) if @item.tab_path != params[:id]
    end
  end

  rescue_from IndexError, Cmless::Error do
    raise ActionController::RoutingError.new("Not Found")
  end
end
