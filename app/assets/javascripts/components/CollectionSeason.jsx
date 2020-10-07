class CollectionSeason extends React.Component {

  render() {
    let cardData = this.props.cardData
    let classes = 'season'

    let sliceName
    if(this.props.type == 'seasons' || this.props.type == 'clips'){
      sliceName = 'Season'
    } else if(this.props.type == 'episodes'){
      sliceName = 'Episode'
    }

    // if were searching, expand them all
    let expanded = (this.props.expanded == this.props.index || this.props.searching)
    classes += expanded ? ' season-open' : ''
    let sty

    // let height = document.getElementById('container').clientHeight;
    sty = {backgroundImage: 'url(' + this.props.seasonImage + ')'}

    return (
      <div id={ this.props.id } style={ sty } className={ classes }>

        <h2 className="season-title" onClick={ () => this.props.expand(this.props.index) }>
          <div className="season-title-text">
            { sliceName } { this.props.seasonNumber }
          </div>
        </h2>
        <div className="season-subtitle">
          { this.props.description }
        </div>

        <div className="season-body">
          <CollectionCards
            seasonId={ this.props.id }
            handleClipClick={ this.props.handleClipClick }
            clipClickGuid={ this.props.clipClickGuid }
            cards={ cardData }
          />
        </div>

        <div className="season-mask"></div>
      </div>
    )
  }
}
