class TreasuriesController < ApplicationController

  def show
    @item = Treasury.new(params[:title])
  end
end