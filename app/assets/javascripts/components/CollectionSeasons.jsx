class CollectionSeasons extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null,
      search: "",

      // what guid we done clipclicked
      clipClickGuid: null
    }

    this.handleOnChange = this.handleOnChange.bind(this)
    this.expand = this.expand.bind(this)
    this.clearSearch = this.clearSearch.bind(this)
    this.handleClipClick = this.handleClipClick.bind(this)
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
    return val ? val.toLowerCase() : ""
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

  clearSearch(){
    this.setState({search: ""})
  }

  handleClipClick(guid){
    this.setState({clipClickGuid: guid})
    console.log(" I CLICK AN CLICK AND CLICK", guid, this.state.clipClickGuid)
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

      if(cards.length == 0){
        continue
      }

      seasons.push( 
        <CollectionSeason
          key={i}

          seasonImage={ season.seasonImage }
          description={ season.description }

          expanded={ this.state.expanded }
          expand={ this.expand }

          clipClickGuid={ this.state.clipClickGuid }
          handleClipClick={ this.handleClipClick }          

          searching={ this.state.search.length > 0 }
          index={index}
          seasonNumber={ season.seasonNumber }
          cardData={ cards }
        />
      )
    }

    if(seasons.length == 0){
      seasons = (
        <h1 className="row treasury-noresults">
          Sorry, no records matched your search. Please revise your search terms.
        </h1>
      )
    }

    return seasons
  }

  render() {
    let seasons = this.drawSeasons()
    return (
      <div className="">
        <CollectionSearch
          clearSearch={ this.clearSearch }
          handleOnChange={ this.handleOnChange }
          seasons={ seasons }
        />
        { seasons }
      </div>
    )
  }
}