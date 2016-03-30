class OverrideController < ApplicationController
  def show
    begin
      @override = Override.find_by_path(params[:path])
    rescue IndexError
      return render_404
    end

    @page_title = @override.title
    params[:path] = nil # search widget grabs ALL parameters.
    render :show
  end
end
