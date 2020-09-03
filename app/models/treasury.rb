class Treasury
  SEASONS = 0
  EPISODES = 1
  attr_reader :data

  # YML style
  # def initialize(title)
  #   filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

  #   raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
  #   # @file = 
  #   @data = YAML.load( File.read(filepath) )
  # end

  def initialize(title, type)

    # get a bucket of images to draw from
    @cooke_images = images



    if type == SEASONS
      filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

      raise "Bad Treasury Name! No File!" unless File.exist?(filepath)


  
      @data = YAML.load( File.read(filepath) )

      pbs = RSolr.connect(url: 'http://localhost:8983/solr/')
                      .get('select', params: {
                             'q' => "*:*",
                             # 'fl' => 'id,short_title,thumbnail_src,asset_description',
                             # 'sort' => 'short_title asc',
                             'rows' => '1000' # Solr default is 10.
                           })['response']['docs'].map { |doc| PBCore.new( doc['xml'] ) }

      # year for testing
      # season_data = docs.reject {|g| g.year.nil? }.group_by {|pb| pb.year }

      # this is to grab every miniseries once - gross!
      season_data = pbs.uniq {|pb| pb.miniseries_title }.group_by {|pb| pb.season_number }

      # combine yml data with docs
      @data["seasons"] = @data["seasons"].map do |season|
        snumber = season["seasonNumber"].to_s

        card_data = []
        # one season's card data
        if season_data[snumber]
          card_data = season_data[snumber].map {|pb| card_from_mini(pb.miniseries_title, pb.miniseries_description) }
        end

        season_from_cards( snumber, season["description"], card_data )
      end
    else

      # normalized, from url
      miniseries_title = title

      # get every pbcore record that shares this miniseries_title
      minipbs = RSolr.connect(url: 'http://localhost:8983/solr/').get('select', params: {'q' => "*:*", 'fl' => 'xml', 'rows' => '10000'})['response']['docs'].map { |doc| PBCore.new( doc['xml'] ) }.select {|pb| pb.miniseries_title &&  miniseries_title == normalize_mini_title(pb.miniseries_title) }

      # program number AKA episode number
      miniseries_data = minipbs.group_by {|pb| pb.program_number }

      @data = {}
      @data["title"] = minipbs.first.miniseries_title

      # stored pretty redundantly but thats how the cookie catalogs
      miniseries_description  = minipbs.first.miniseries_description
      @data["description"] = miniseries_description
      @data["seasons"] = []

      miniseries_data.each do |episode_number, episode_pbs|


        card_data = episode_pbs.map {|pb| card_from_pbcore(pb) }
        # for miniseries page, a 'season' is ONE EPISODE
        @data["seasons"] << season_from_cards(episode_number, nil, card_data)
      end
    end

  end

  # def all_miniseries_titles

  # end

  def images
    [
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/2025552.jpg",
      # "https://s3.amazonaws.com/openvault.wgbh.org/carousel/alistair_cooke_banner.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/Mezzanine_584.jpg.focalcrop.1200x630.50.10.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/cooke-headshot.jpg",
      # "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/download.jpeg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/Alistair-Cookie.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/maxresdefault.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/p01vzv4w.jpg",
      
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/1280px-Bunratty_Castle_South_Solar_01.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/20180814-Parlor-023.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/3c304-blue-drawing-roombuckinghampalace.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/450c3aff51adacec1954c15fd524b6bb.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/DrawingRoom1-2.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/HOL_3016.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/OSMstuzB7-8hO7LQNWjauYkBPstvyuv1Y5PDXlPBTOM.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/The-Fife-Arms-Drawing-Room.-Ancient-Quartz-by-Zhang-Enli.-Photo-credit-Sim-Canetty-Clarke-e1553790189459-scaled.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/d3ddd-the-yellow-drawing-room-credit-tim-imrie.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/f20ab-invererycastledrawingroom.png",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/herter.jpg",
      "https://s3.amazonaws.com/openvault.wgbh.org/treasuries/alistair-cooke/victorian.jpg",

    ]
  end

  # this is for slices, whther seasons or minis
  def season_from_cards(season_number, season_description, card_data, season_image=nil)
    {
      "seasonImage" => season_image || random_cooke_image,
      "description" => season_description,
      "seasonNumber" => season_number,
      "cardData" => card_data
    }
  end

  def normalize_mini_title(title)
    return title.downcase.gsub(' ', '-').gsub(',','').gsub(/[',:;\.\(\)]/, '')
  end

  # this is for mini CARDS
  def card_from_mini(title, desc)
    {
      "type" => "miniseries",
      "title" => title,
      "description" => desc,
      "recordLink" => "/miniseries/#{ normalize_mini_title(title) }",
      
      # they dont want no card image
      # "cardImage" => random_cooke_image,
    }
  end

  # this is for mini SLICES
  # def miniseries_from_pbcores(season_number, season_description, pbcores)
  #   {
  #     "seasonImage" => random_cooke_image,
  #     "description" => season_description,
  #     "seasonNumber" => season_number,
  #     "cardData" => pbcores.map {|pb| card_from_pbcore(pb) }
  #   }
  # end

  # this is for program material CARDS
  def card_from_pbcore(pbcore)
    {
      "type" => "pbcore",

      "title" => pbcore.title,
      "description" => pbcore.program_description,
      "date" => pbcore.date,
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

  def title
    @data["title"]
  end

  def poster_image
    @data["posterImage"]
  end

  def description
    @data["description"]
  end

  def seasons
    @data["seasons"]
  end
end