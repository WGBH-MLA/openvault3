class CollectionSeason extends React.Component {

  render() {
    let cardData = this.props.cardData
    let classes = 'season'

    // if were searching, expand them all
    let expanded = (this.props.expanded == this.props.index || this.props.searching)
    classes += expanded ? ' season-open' : ''
    let sty

    // let height = document.getElementById('container').clientHeight;
    sty = {backgroundImage: 'url(' + this.props.seasonImage + ')'}

    return (
      <div style={ sty } className={ classes }>

        <h2 className="season-title" onClick={ () => this.props.expand(this.props.index) }>
          <div className="season-title-text">
            Season { this.props.seasonNumber }
          </div>
        </h2>
        <div className="season-subtitle">
          { this.props.description }
        </div>

        <div className="season-body">
          <CollectionCards cards={ cardData } />
        </div>

        <div className="season-mask"></div>
      </div>
    )
  }
}
