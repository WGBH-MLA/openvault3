class Treasury
  SEASONS = 0
  EPISODES = 1
  attr_reader :data

  def initialize(title, type)

    # get a bucket of images to draw from
    @cooke_images = images

    if type == SEASONS
      filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

      raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
  
      @data = YAML.load( File.read(filepath) )
      @data["type"] = 'seasons'

      pbs = RSolr.connect(url: 'http://localhost:8983/solr/')
                      .get('select', params: {
                             'q' => "*:*",
                             'rows' => '1000' # Solr default is 10.
                           })['response']['docs'].map { |doc| PBCore.new( doc['xml'] ) }


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
      @data["type"] = 'episodes'
      @data["title"] = minipbs.first.miniseries_title

      tseries = Treasury.treasury_series
      home_treasury = tseries.keys.find {|treasury_title| tseries[ treasury_title ][:miniseries_titles].include?( @data["title"] ) }

      if home_treasury
        @data["treasury_url"] = "/treasuries/#{home_treasury}"
        @data["treasury_nice_title"] = tseries[home_treasury][:nice_treasury_title]
      end

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
        nice_treasury_title: 'Alistair Cooke Masterpiece Collection'
      }

    }

  end

end