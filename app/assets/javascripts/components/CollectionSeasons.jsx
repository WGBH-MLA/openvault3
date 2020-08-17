class CollectionSeasons extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null
    }

    this.expand = this.expand.bind(this)
  }

  expand(index){
    this.setState({expanded: index})
  }

  drawSeasons(){
    let seasons = []
    let season
    let index
    for(var i=0; i<this.props.seasons.length; i++){
      season = this.props.seasons[i]
      index = i+1
      
      seasons.push( 
        <CollectionSeason
          key={i}

          seasonImage={ season.seasonImage }

          expand={ this.expand }
          expanded={ this.state.expanded }
          index={index}
          seasonNumber={ season.seasonNumber }
          cardData={ season.cardData }
        />
      )
    }

    return seasons
  }

  render() {
    let seasons = this.drawSeasons()
    return (
      <div className="">
        { seasons }
      </div>
    )
  }
}