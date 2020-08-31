class CollectionSeasons extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null,
      search: ''
    }

    this.handleOnChange = this.handleOnChange.bind(this)
    this.expand = this.expand.bind(this)
  }

  // get search value
  handleOnChange(event){
    let val = event.target.value
    this.setState({search: val})
  }

  searchCards(cards, val){
    // check each card for search term
    return cards.filter( (card) => { return this.searchCard(card, val) } )
  }

  searchCard(card, val){
    // console.log("val ", val)
    // console.log("title ", card.title)
    // console.log("desc ", val)

    
    val = this.normalize(val)
    let title = this.normalize(card.title)
    let description = this.normalize(card.description)

    return (title && title.includes(val)) || (description && description.includes(val))
  }

  normalize(val){
    return val ? val.toLowerCase() : ''
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
      
      let cards = season.cardData
      if(this.state.search.length > 0){
        cards = this.searchCards(cards, this.state.search)
      }

      // if(!cards || cards.length == 0){
      //   cards = season.cardData
      // }
      if(cards.length == 0){
        continue
      }

      seasons.push( 
        <CollectionSeason
          key={i}

          seasonImage={ season.seasonImage }
          description={ season.description }
          expand={ this.expand }
          expanded={ this.state.expanded }
          searching={ this.state.search.length > 0 }
          index={index}
          seasonNumber={ season.seasonNumber }
          cardData={ cards }
        />
      )
    }

    if(seasons.length == 0){
      seasons = "No episodes matched your search... Please revise your search terms and try again."
    }

    return seasons
  }

  render() {
    let seasons = this.drawSeasons()
    return (
      <div className="">
        <CollectionSearch
          handleOnChange={ this.handleOnChange }
          seasons={ seasons }
        />
        { seasons }
      </div>
    )
  }
}