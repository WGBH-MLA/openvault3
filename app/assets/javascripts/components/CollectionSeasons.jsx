class CollectionSeasons extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null
    }

    this.expand = this.expand.bind(this)
  }

  expand(index){
    let setto
    if(this.state.expanded == index){
      setto = null
    } else {
      setto = index
    }
    this.setState({expanded: setto})
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
          description={ season.description }
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