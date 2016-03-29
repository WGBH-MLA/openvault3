class OverrideController < ApplicationController
  def show
    @override, status = begin
      [Override.find_by_path(params[:path]), 200]
    rescue
      [Override.find_by_path('404'), 404]
    end
    @page_title = @override.title
    params[:path] = nil # search widget grabs ALL parameters.
    render :show, status: status
  end
end
