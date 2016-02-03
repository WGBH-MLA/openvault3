class TabbedController < ApplicationController
  def index
    @all = tab_class.all
  end

  def show
    @item = tab_class.find_by_path(params[:id])
    @page_title = @item.title
    unless (params[:tab])
      redirect_to('/'+params[:controller]+'/'+@item.tab_path)
    end
  end
end
