class CollectionCard extends React.Component {
  clipClickAndExpand(){
    this.props.handleClipClick(this.props.guid)
    this.props.expand(this.props.guid)
  }

  render() {
    let classes
    let sty
    let linkText
    if(this.props.type == "miniseries"){
      linkText = "View Episodes"
    } else {
      linkText = "See Full Record"
    }

     if(this.props.clipCard && !this.props.clipCardActive) {
      classes = "card-container clipclick "
      if(this.props.cardImage){
        sty = {backgroundImage: "url(" + this.props.cardImage + ")"}
      }
    } else if(this.props.clipCard) { 
      classes = "card-container card-container-video"

    } else {
      classes = "card-container "
      if(this.props.cardImage){
        sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}
      }
    }

    classes += this.props.expanded == this.props.guid ? ' expanded' : ''

    let programNumber, date, description

    if(this.props.programNumber){
      programNumber = "Program " + this.props.programNumber
    }

    // DO NOT show date values for miniseries cards, because we arent sure we got the earlier date from mini
    // if(!this.props.type == 'miniseries' && this.props.date){
    //   date = "(" + this.props.date + ")"
    // }

    if(this.props.date){
      date = this.props.date
    }

    let pnAndDate
    if( this.props.date || this.props.programNumber ){
      pnAndDate = ( <div className="card-text">{ programNumber } { date }</div> )
    }

    // only show description on expanded card
    if(this.props.expanded == this.props.guid && this.props.description){
      description = ( <div className="card-text">{ this.props.description }</div> )
    }

    if(this.props.clipCard){
      if(this.props.clipCardActive){
        return (
          <div id={ this.props.guid } style={ sty } onClick={ () => this.props.expand(this.props.guid) } className={ classes }>
            <div className="card-video">
              <iframe className="card-iframe" src={ this.props.embedLink } />
            </div>
          </div>
        )  
      } else {
        return (
          <div id={ this.props.guid } style={ sty } className={ classes }>
            <div className="card-container-mask"></div>

            <div onClick={ () => this.clipClickAndExpand() } className="card-clipclick-container">
              <h1 className="card-title">
                { this.props.title }
              </h1>

              { pnAndDate }

              { description }
            </div>

            <a href={ this.props.recordLink } className="card-showfull">
              Watch Alistair
            </a>
          </div>
        )
      }

    } else {
        
      return (
        <div id={ this.props.guid } style={ sty } onClick={ () => this.props.expand(this.props.guid) } className={ classes }>
          <div className="card-container-mask"></div>

          <h1 className="card-title">
            { this.props.title }
          </h1>

          { pnAndDate }

          { description }

          <a href={ this.props.recordLink } className="card-showfull">
            { linkText }
          </a>
        </div>
      )
    }
  }
}
