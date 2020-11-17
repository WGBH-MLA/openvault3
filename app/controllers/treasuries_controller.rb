class TreasuriesController < ApplicationController
  SEASONS = 0
  CLIPS = 1
  EPISODES = 2
  # all seasons
  def show
    # TODO: not this -> hardcoding this, because people want the url for cooke to be /collections/cooke
    # but its not a special collection
    # @item = Treasury.new(params[:title], SEASONS)
    @item = Treasury.new('alistair-cooke', SEASONS)
  end

  def miniseries
    @item = Treasury.new(params[:title], EPISODES)
    render 'treasuries/show'
  end

  def clip
    @item = Treasury.new('alistair-cooke', CLIPS)
    render 'treasuries/show'
  end

  def list
    @list_seasons = Treasury.generate_list_seasons
  end
end
