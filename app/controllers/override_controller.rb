class OverrideController < ApplicationController
  def show
    @override = Override.find_by_path(params[:path])

    @page_title = @override.title
    params[:path] = nil # search widget grabs ALL parameters.
    render :show
  end

  rescue_from IndexError, with: :render_404
end
