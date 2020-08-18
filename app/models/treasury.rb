class Treasury

  attr_reader :data

  def initialize(title)
    filepath = File.join(Rails.root, "app", "views", "treasuries", "data", "#{title}.yml")

    raise "Bad Treasury Name! No File!" unless File.exist?(filepath)
    # @file = 
    @data = YAML.load( File.read(filepath) )
  end

  def title
    @data["title"]
  end

  def seasons
    @data["seasons"]
  end
end