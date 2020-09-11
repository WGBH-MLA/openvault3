class Treasury
  SEASONS = 0
  EPISODES = 1
  attr_reader :data

  def self.xml_docs
    Rails.cache.fetch("cooke_xml_records_5") do
      # sort all cooke records by date, as xml, so it FAST
      RSolr.connect(url: 'http://localhost:8983/solr/').get('select', params: {'q' => "special_collections:alistair-cooke", 'fl' => 'xml', 'rows' => '1000'})['response']['docs'].map {|doc| doc['xml'] }.sort_by {|xml| Treasury.broadcast_date_from_xml(xml) }
    end
  end

  def self.generate_list_seasons
    # this takes... a long time
    Rails.cache.fetch("cooke_list_5") do
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

      @list_seasons
    end
  end

  def self.broadcast_date_from_xml(xml)
    matchdata = xml.match(/<pbcoreAssetDate dateType="Broadcast">(.{8,10})<\/pbcoreAssetDate>/)
    matchdata ? Date.strptime( matchdata[1], '%m/%d/%Y' ) : DateTime.now
  end

  def self.miniseries_title_from_xml(xml)
    matchdata = xml.match(/<pbcoreTitle titleType="Miniseries">(.*?)<\/pbcoreTitle>/)
    matchdata ? matchdata[1] : nil
  end

  def self.normalize_mini_title(title)
    return title.downcase.gsub(' ', '-').gsub(/\W/, '')
  end
  
  def initialize(title, type)

    # get a bucket of image urls to draw from
    @cooke_images = images

    if type == SEASONS
      filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

      raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
  
      @data = YAML.load( File.read(filepath) )
      @data["type"] = 'seasons'

      # UNIQ BASED ON raw XML, to Save MANY SECONDS
      pbs = Treasury.xml_docs.uniq {|xml| Treasury.miniseries_title_from_xml(xml) }.map { |xml| PBCore.new( xml ) }
      season_data = pbs.group_by {|pb| pb.season_number }

      # combine yml data with docs
      @data["seasons"] = @data["seasons"].map do |season|
        snumber = season["seasonNumber"].to_s

        card_data = []
        # one season's card data
        if season_data[snumber]
          card_data = season_data[snumber].map {|pb| card_from_mini(pb.miniseries_title, pb.miniseries_description, pb.broadcast_date) }
        end

        season_from_cards( snumber, season["description"], card_data, 'seasons' )
      end
    else

      # normalized, from url 
      miniseries_title = title
      # get every pbcore record that shares this miniseries_title
      minipbs = Treasury.xml_docs.select {|xml| miniseries_title == Treasury.normalize_mini_title( Treasury.miniseries_title_from_xml(xml) ) }.map {|xml| PBCore.new(xml) }

      # program number AKA episode number
      miniseries_data = minipbs.group_by {|pb| pb.program_number }

      @data = {}
      @data["type"] = 'episodes'

      nice_miniseries_title = minipbs.first ? minipbs.first.miniseries_title : 'Miniseries Title Not Found'
      @data["title"] = nice_miniseries_title

      tseries = Treasury.treasury_series
      home_treasury = tseries.keys.find {|treasury_title| tseries[ treasury_title ][:miniseries_titles].include?( @data["title"] ) }

      if home_treasury
        @data["treasury_url"] = "/treasuries/#{home_treasury}"
        @data["treasury_nice_title"] = tseries[home_treasury][:treasury_nice_title]
      end

      # stored pretty redundantly but thats how the cookie catalogs
      miniseries_description  = minipbs.first ? minipbs.first.miniseries_description : ""
      @data["description"] = miniseries_description
      @data["seasons"] = []

      miniseries_data.each do |episode_number, episode_pbs|
        card_data = episode_pbs.map {|pb| card_from_pbcore(pb) }
        # for miniseries page, a 'season' is ONE EPISODE
        @data["seasons"] << season_from_cards(episode_number, nil, card_data, 'episodes')
      end
    end
  end

  def images
    [
      # prod stuff
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masconviece_Theatre_Season20_Scoop_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/MastOpen_01.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/MastOpen_02.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/MastOpen_03.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/MastOpen_04.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/MastOpen_05.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season13_Irish_RM_barcode289530.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season14_Jewel_in_Crown_Barcode289531.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season15_Bleak_House_Color_Barcode289532.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season15_Bleak_House_barcode289532.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season16_Paradise_Posponed_Barcode289526.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season16_Paradise_Postponed_Bar_Barcode289526.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season16_Paradise_Postponed_StudioSetup_Barcode289526.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season17_Fortunes_of_War_Color_Barcode289524.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season17_Fortunes_of_War_Masterpiece Theatre.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season17_Sorrell_Son_Barcode289525.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season19_Traffik_Barcode289517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season19_Traffik_Color__Barcode 289517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season19_Yellow_Wallpaper_Color_Barcode289517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_20th_Anniversary_Barcode289517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Alistair_Favorites_Color_Barcode289517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Ginger_Tree_Color_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Heat_of_Day_Color_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Heat_of_Day_barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Jeeves_Wooster_Color_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Scoop_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season20_Scoop_Color_Barcode289518.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_Love_Cold_Climate_cooke_on_set_barcode350101_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_Love_Cold_Climate_cooke_on_set_barcode350101_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_edward_mrs_simpson_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_edward_mrs_simpson_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_love_cold_climate_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_love_cold_climate_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_love_cold_climate_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_love_cold_climate_4.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_11_townlike_alice_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_12_On_approval_Cooke_2..jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_Beatrix_Potter_Cooke_on_set_barcode383427.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_citadel_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_citadel_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_nancy_astor_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_nancy_astor_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_pictures_Cooke_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_13_pictures_Cooke_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_all_for_love.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_jewel_in_crown_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_jewel_in_crown_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_jewel_in_crown_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_jewel_in_crown_5.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_14_jewel_in_crown_6.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_15_bleak_house.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_goodbye_mr_chips_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_goodbye_mr_chips_3_Cooke.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_paradise_postponed_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_paradise_postponed_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_paradise_postponed_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_paradise_postponed_4.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_paradise_postponed_5.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_silas_marner_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_16_silas_marner_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_17_bretts_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_17_day_after_fair_4.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_17_northanger_abbey_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_17_northanger_abbey_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_18_all_passion_spent_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_18_heaven_on_earth.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_18_talking_heads_bed_lentils_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_18_very_british_coup.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_18_wreath_roses_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_glory_enough_for_all_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_glory_enough_for_all_4.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_glory_enough_for_all_5.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_piece_of_cake_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_piece_of_cake_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_19_piece_of_cake_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_Jeeves_Wooster_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_anniversary_special_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_anniversary_special_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_anniversary_special_20200907015711.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_ginger_tree_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_ginger_tree_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_room_ones_own_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_scoop_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_20_scoop_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_21_clarissa.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_21_dolls_house_1.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_21_dolls_house_2.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Masterpiece_Theatre_Season_21_dolls_house_3.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/Staff_HenryBectonAlistairCooke_01.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/alistair_cooke_on_set_masterpiece_01.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/alistair_cooke_on_set_masterpiece_02.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/carliament-544751.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/castle-336498.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/cemair-beech-1900-143396.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/citadel.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/dunrobin-453164.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/fingerprint-255904.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/fog-1494431.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/henryviii.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/jewelincrown.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/library-863148.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/london-5102512.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/manor-house-4299218.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/mohicans.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/parliament-544751.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/philatelist-1844078.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/royal-1691418.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/royal-garden-2529542.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/space-4161418.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/texture-1362879.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/vienna-434517.jpg',
      'https://s3.amazonaws.com/openvault.wgbh.org/treasuries/cooke-production-flavor/western-style-2312246.jpg',
    ]
  end

  # this is for slices, whther seasons or minis
  def season_from_cards(season_number, season_description, card_data, type, season_image=nil)
    {
      "seasonImage" => season_image || random_cooke_image,
      "description" => season_description,
      "seasonNumber" => season_number,
      "cardData" => card_data,
      "type" => type
    }
  end

  # this is for mini CARDS
  def card_from_mini(title, desc, date)
    {
      "type" => "miniseries",
      "title" => title,
      "description" => desc,
      "recordLink" => "/miniseries/#{ Treasury.normalize_mini_title(title) }",
      "sortDate" => date,
      "date" => date.strftime('%m/%d/%Y'),

      # generate a unique id for mini cards for scrollTo js behavior
      "guid" => SecureRandom.uuid,
      # they dont want no card image
      # "cardImage" => random_cooke_image,
    }
  end

  # this is for program material CARDS
  def card_from_pbcore(pbcore)
    {
      "type" => "pbcore",

      "title" => pbcore.title,
      "description" => pbcore.program_description,
      # no need to sort on this within a single episode
      "date" => pbcore.broadcast_date_raw,
      "programNumber" => pbcore.program_number,
      "guid" => pbcore.id,
      "recordLink" => "/catalog/#{pbcore.id}",
      "embedLink" => "/embed/card/#{pbcore.id}",

      # no card image for you
      # "cardImage" => random_cooke_image,

      "clipCard" => pbcore.is_clip?
    }
  end

  def random_cooke_image
    @cooke_images.shuffle!.pop || images.sample
  end

  def is_episodes?
    @data["type"] == 'episodes'
  end

  def title
    @data["title"]
  end

  def poster_image
    @data["posterImage"]
  end

  def description
    @data["description"]
  end

  def alt_link
    @data["altLink"]
  end

  def seasons
    @data["seasons"]
  end

  def treasury_url
    @data["treasury_url"]
  end

  def treasury_nice_title
    @data["treasury_nice_title"]
  end

  def self.treasury_series
    {
      "alistair-cooke" => {
        miniseries_titles:[
        "First Churchills, The",
        "Spoils of Poynton, The",
        "Possessed, The",
        "Pere Goriot",
        "Jude the Obscure",
        "Gambler, The",
        "Resurrection",
        "Cold Comfort Farm",
        "Six Wives of Henry VIII, The",
        "Elizabeth R",
        "Last of the Mohicans, The",
        "Vanity Fair",
        "Cousin Bette",
        "Moonstone, The (1972)",
        "Tom Brown's Schooldays",
        "Point Counter Point",
        "Golden Bowl, The",
        "Clouds of Witness",
        "Man Who Was Hunting Himself, The",
        "Unpleasantness at the Bellona Club, The",
        "Little Farm, The",
        "Upstairs, Downstairs, Season 1",
        "Edwardians, The",
        "Murder Must Advertise",
        "Upstairs, Downstairs, Season 2",
        "Country Matters, Season 1",
        "Vienna 1900",
        "Nine Tailors, The",
        "Shoulder to Shoulder",
        "Notorious Woman",
        "Upstairs, Downstairs, Season 3",
        "Cakes and Ale",
        "Sunset Song",
        "Madame Bovary",
        "How Green Was My Valley",
        "Five Red Herrings",
        "Upstairs, Downstairs, Season 4",
        "Poldark, Season 1 (1977)",
        "Dickens of London",
        "I, Claudius",
        "Anna Karenina (1978)",
        "Lillie",
        "Our Mutual Friend (1978)",
        "Poldark, Season 2 (1978)",
        "Mayor of Casterbridge, The",
        "Duchess of Duke Street, The, Season 1",
        "20th Anniversary Favorites: The Six Wives of Henry VIII: Catherine Howard",
        "Country Matters, Season 2",
        "Kean",
        "Love for Lydia",
        "Duchess of Duke Street, The, Season 2",
        "Therese Raquin",
        "My Son, My Son",
        "Disraeli",
        "Crime and Punishment",
        "Pride and Prejudice",
        "Testament of Youth",
        "Danger UXB",
        "Town Like Alice, A",
        "Edward And Mrs. Simpson",
        "Flame Trees Of Thika, The",
        "I Remember Nelson",
        "Love In A Cold Climate",
        "Flickers",
        "To Serve Them All My Days",
        "Good Soldier, The",
        "Winston Churchill: The Wilderness Years",
        "On Approval",
        "Drake's Venture",
        "Private Schulz",
        "Sons and Lovers",
        "Pictures",
        "Citadel, The",
        "Irish R.M., The, Season 1",
        "Tale of Beatrix Potter, The",
        "Nancy Astor",
        "Barchester Chronicles, The",
        "Jewel in the Crown, The",
        "All for Love",
        "Strangers and Brothers",
        "Last Place on Earth, The",
        "Bleak House (1985)",
        "Lord Mountbatten: The Last Viceroy",
        "By the Sword Divided, Season 1",
        "Irish R.M., The, Season 2",
        "Paradise Postponed",
        "Goodbye, Mr. Chips (1987)",
        "Lost Empires",
        "Silas Marner",
        "Star Quality: Noel Coward Stories",
        "Death of the Heart, The",
        "Love Song",
        "Bretts, The, Season 1",
        "Northanger Abbey",
        "Sorrell and Son",
        "Fortunes of War",
        "Day After the Fair",
        "David Copperfield (1988)",
        "By the Sword Divided, Season 2",
        "Perfect Spy, A",
        "Heaven on Earth",
        "Wreath of Roses, A",
        "Very British Coup, A",
        "All Passion Spent",
        "Talking Heads: Bed Among the Lentils",
        "Christabel",
        "Charmer, The",
        "Bretts, The, Season 2",
        "And a Nightingale Sang",
        "Precious Bane",
        "Glory Enough for All",
        "Tale of Two Cities, A",
        "Yellow Wallpaper, The",
        "After the War",
        "Real Charlotte, The",
        "Dressmaker, The",
        "Traffik",
        "Piece of Cake",
        "Heat of the Day, The",
        "Ginger Tree, The",
        "Jeeves and Wooster, Season 1",
        "Scoop",
        "Room of One's Own, A",
        "Backstage at Masterpiece Theatre: 20th Anniversary Special",
        "House of Cards",
        "Shiralee, The",
        "Summer's Lease",
        "20th Anniversary Favorites: I, Claudius: Zeus, By Jove",
        "20th Anniversary Favorites: All for Love: A Dedicated Man",
        "20th Anniversary Favorites: The Jewel in the Crown: Crossing the River",
        "20th Anniversary Favorites: The Tale of Beatrix Potter",
        "20th Anniversary Favorites: Upstairs, Downstairs, Season 1: Guest of Honor",
        "20th Anniversary Favorites: Upstairs, Downstairs",
        "20th Anniversary Favorites: The Flame Trees Of Thika: Happy New Year",
        "20th Anniversary Favorites: Upstairs, Downstairs, Series IV: All the King’s Horses",
        "20th Anniversary Favorites: Upstairs, Downstairs, Series IV: Such A Lovely Man",
        "20th Anniversary Favorites: On Approval",
        "20th Anniversary Favorites: Elizabeth R: The Lion's Cub",
        "Parnell and the Englishwoman",
        "Titmuss Regained",
        "Adam Bede",
        "Doll's House, A",
        "Clarissa",
        "Henry V",
        "Perfect Hero, A",
        "Portrait of a Marriage",
        "Question of Attribution, A",
        "Best of Friends, The",
        "Memento Mori",
        "Two Monologues: In My Defense; A Chip in the Sugar",
        "Secret Agent, The",],

        # for backlinks
        treasury_nice_title: 'Alistair Cooke Masterpiece Collection'
      }

    }

  end

end