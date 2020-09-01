class CollectionCards extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null
    }

    this.expand = this.expand.bind(this)
  }

  expand(index){
    let newExpand
    // if we already expanded this one, close it
    if(this.state.expanded != index){
      newExpand = index
    }

    this.setState({expanded: newExpand})
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
          key={i}
          
          index={index}

          // from pbcore model
          title={ card.title }
          description={ card.description }
          programNumber={ card.programNumber }
          date={ card.date }

          // catalog link
          recordLink={ card.recordLink }
          
          cardImage={ card.cardImage }
          expanded={ this.state.expanded }
          expand={ this.expand }
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