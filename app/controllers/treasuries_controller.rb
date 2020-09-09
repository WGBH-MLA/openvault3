class TreasuriesController < ApplicationController
  SEASONS = 0
  EPISODES = 1
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

  def list
    @list_seasons = []

    # a data structure only a mother could love
    seasons = Treasury.new('alistair-cooke', SEASONS).seasons
    seasons.each_with_index do |season,i|
      list_season = {seasonNumber: season["seasonNumber"], miniseries: []}
      
      season["cardData"].each do |miniseries|
         list_miniseries = { miniseriesTitle: miniseries["title"], miniseriesUrl: miniseries["recordLink"], miniseriesEpisodes: [] }

        Treasury.new(Treasury.normalize_mini_title( miniseries["title"] ), EPISODES).seasons.each do |episode|

          episode["cardData"].each do |epicard|

            # DONT GIMME ANY DAMN CLIPS
            if epicard["clipCard"] != true
              list_miniseries[:miniseriesEpisodes] << { episodeTitle: epicard["title"], programNumber: epicard["programNumber"], episodeUrl: epicard["recordLink"] }
            end
          end
        end

         list_season[:miniseries] << list_miniseries
      end

      @list_seasons << list_season
    end
  end

  # def bio
  # end
end


# [

#   {
#     seasonnumber:,
#     miniserieses: [
#       {
#         minititle:,
#         episodes: [
#           {
#             episodetitle:
#             episodelink:
#           }
#         ]

#       }

#     ]
#   }

# ]
