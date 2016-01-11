class SeriesController < ApplicationController
  def index
    @series_by_first_letter = SeriesList.new.by_first_letter
  end
end