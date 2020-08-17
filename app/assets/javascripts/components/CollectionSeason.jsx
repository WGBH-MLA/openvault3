class CollectionSeason extends React.Component {
  render() {
    let cardData = this.props.cardData;
    let classes = 'season'
    classes += this.props.expanded == this.props.index ? ' season-open' : ''

    let img = (<img className="season-image" src={ this.props.seasonImage } />)
    img = null

    return (
      <div className={ classes }>
        <h2 className="season-title" onClick={ () => this.props.expand(this.props.index) }>
          <div className="season-title-text">
              Season { this.props.seasonNumber }
          </div>
          
          { img }
        </h2>

        <div className="season-body">
          <CollectionCards cards={ cardData } />
        </div>
      </div>
    )
  }
}
