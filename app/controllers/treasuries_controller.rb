class TreasuriesController < ApplicationController
  SEASONS = 0
  EPISODES = 1
  # all seasons
  def show
    @item = Treasury.new(params[:title], SEASONS)
  end

  def miniseries
    @item = Treasury.new(params[:title], EPISODES)


    render 'treasuries/show'
  end
end