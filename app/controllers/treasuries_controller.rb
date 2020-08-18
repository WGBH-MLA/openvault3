class TreasuriesController < ApplicationController

  def show
    cards = [
              {
                title: "How Big Do Things Look?",
                description: "What is psychology? According to Dr. Boring, it is a scientific story of men getting along in the changing world. Dr. Boring talks about 3 departments in the nervous system: information department, behavior, and action.",
                img: "https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_thumbnails/V_7D937698FAA1489882C6BFDC8E62849D.jpg",
                recordLink: "https://www.pbs.org/wgbh/masterpiece/"
              },
              {
                title: "Is Man Free To Choose?",
                description: "This series (of 38 programs) presents Dr. Edwin Boring's famous psychology course which he teaches at Harvard. He gives the basic facts and principles necessary to uncover man's awareness, thought and behavior.",
                img: "https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_thumbnails/V_3F5E87799D7D478AA3E022BA245986C1.jpg",
                recordLink: "https://www.britannica.com/biography/Alistair-Cooke"
              },
              {
                title: "Nature Vs. Nurture",
                description: "Stress will be placed on the biological development of these phenomena and the role of heredity and learning in determining human abilities and human efficiency. Dr. Boring recaps the last episode when he talked about sex, and focuses on the problems of nature and biological differences reflected in psychology.",
                img: "http://openvault.wgbh.org/catalog/V_87A4D8EB4DF044D48313ED7FA6F0A2A7",
                recordLink: "https://www.bbc.co.uk/programmes/b00f6hbp"
              },
              {
                title: "What The Brain Does",
                description: "Then he talks about the centers of the brain and their projections: motor, touch, vision, hearing, and frontal. Three more diagrams are shown, including a topological projection of the areas of brain responsible for face, tongue, hand, arm, trunk.",
                img: "https://s3.amazonaws.com/openvault.wgbh.org/catalog/asset_thumbnails/V_615DF936D24544D8B22261D0C4AD06DD.jpg",
                recordLink: "https://www.wgbh.org/masterpiece/"
              },

            ]
    seasons = [
                {seasonNumber: 1, cardData: cards, seasonImage: 'https://s3.amazonaws.com/openvault.wgbh.org/carousel/carousel_guitar-q-80.jpg'},
                {seasonNumber: 2, cardData: cards, seasonImage: 'https://s3.amazonaws.com/openvault.wgbh.org/carousel/carousel_vietnam-q-80.jpg'},
                {seasonNumber: 3, cardData: cards, seasonImage: 'https://s3.amazonaws.com/openvault.wgbh.org/carousel/carousel_march-q-80.jpg'},
              ] 


    @item = Treasury.new(params[:title])
      require('pry');binding.pry
    
  end
end