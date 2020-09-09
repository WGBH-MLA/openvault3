class CollectionCards extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null
    }

    this.expand = this.expand.bind(this)
  }

  expand(guid){
    let newExpand
    // if we already expanded this one, close it
    // ignore nulls (initial state)
    if(guid && this.state.expanded != guid){
      newExpand = guid
    }

    // scroll to element
    this.setState({expanded: newExpand})

    if(newExpand){
      // scroll to season element so expanded card will be on screen, just below top of season slice
      document.getElementById( this.props.seasonId ).scrollIntoView()
    }
  }

  drawCards(){
    let cards = []
    let card
    let index
    for(var i=0; i<this.props.cards.length; i++){
      card = this.props.cards[i]
      index = i+1

      cards.push(
        <CollectionCard
          key={ i }
          
          index={ index }

          type={ card.type }

          // this is the season element's id, for scrolling
          seasonId={ this.props.seasonId }

          // from pbcore model/miniseries derived data
          title={ card.title }
          description={ card.description }
          programNumber={ card.programNumber }
          date={ card.date }

          guid={ card.guid }
          // catalog link
          recordLink={ card.recordLink }
          embedLink={ card.embedLink }
          
          cardImage={ card.cardImage }

          expanded={ this.state.expanded }
          expand={ this.expand }

          handleClipClick={ this.props.handleClipClick }
          // but is it though?
          clipCard={ card.clipCard }
          clipCardActive={ card.guid == this.props.clipClickGuid }
        />
      )
    }

    return cards
  }

  render() {
    let cards = this.drawCards()
    return (
      <div className="cards-container">
        { cards }
      </div>
    )
  }
}