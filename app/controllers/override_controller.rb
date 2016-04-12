class OverrideController < ApplicationController
  def show
    begin
      @override = Override.find_by_path(params[:path])
    rescue IndexError
      # The error that CMLess throws when it can't find something
      # happens to be IndexError. TODO patch CMLess to throw more
      # specific errors, and rescue from those instead.
      render_404
    end

    @page_title = @override.title
    params[:path] = nil # search widget grabs ALL parameters.
    render :show
  end

  rescue_from Cmless::Cmless::Error, with: :render_404
end
