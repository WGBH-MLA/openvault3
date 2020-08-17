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
          title={ card.title }
          description={ card.description }
          img={ card.img }
          expanded={ this.state.expanded }
          expand={ this.expand }
          record_link={ card.record_link }
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