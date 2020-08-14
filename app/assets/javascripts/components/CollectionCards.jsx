class CollectionCards extends React.Component {
  constructor(props){
    super(props)

    this.state = {
      expanded: null
    }

    this.expand = this.expand.bind(this)
  }

  expand(index){
    console.log("POOP", index)
    this.setState({expanded: index})
  }

  shouldComponentUpdate(nextProps, nextState){
    if(nextState.expanded !== this.state.expanded ){
      return true
    } else {
      return false
    }
  }

  drawCards(){
    let cards = []
    let card
    let index
    for(var i=0; i<this.props.cards.length; i++){
      card = this.props.cards[i]
      console.log(this.state.expanded == i, i)
      index = i+1
      
      cards.push( 
        <CollectionCard
          // 'key is not a prop' lame ass
          key={i}
          index={index}
          title={ card.title }
          description={ card.description }
          img={ card.img }
          isExpanded={ this.state.expanded == index }
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