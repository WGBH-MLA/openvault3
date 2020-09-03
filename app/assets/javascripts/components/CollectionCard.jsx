class CollectionCard extends React.Component {
  clipClickAndExpand(){
    this.props.handleClipClick(this.props.guid)
    this.props.expand(this.props.index)
  }

  render() {
    let classes
    let sty

     if(this.props.clipCard && !this.props.clipCardActive) {
      classes = 'card-container clipclick '
      sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}
    } else if(this.props.clipCard) { 
      classes = 'card-container card-container-video'

    } else {
      classes = 'card-container '
      sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}
    }

    classes += this.props.expanded == this.props.index ? ' expanded' : ''

    let programNumber, date, description

    if(this.props.programNumber){
      programNumber = "Program " + this.props.programNumber
    }

    if(this.props.date){
      date = "(" + this.props.date + ")"
    }

    pnAndDate = ( <div className="card-text">{ programNumber } { date }</div> )

    if(this.props.description){
      description = ( <div className="card-text">{ this.props.description }</div> )
    }

    if(this.props.clipCard){
      if(this.props.clipCardActive){
        return (
          <div style={ sty } onClick={ () => this.props.expand(this.props.index) } className={ classes }>
            <div className="card-video">
              <iframe className="card-iframe" src={ this.props.embedLink } />
            </div>
          </div>
        )  
      } else {
        return (
          <div style={ sty } className={ classes }>
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
        <div style={ sty } onClick={ () => this.props.expand(this.props.index) } className={ classes }>
          <div className="card-container-mask"></div>

          <h1 className="card-title">
            { this.props.title }
          </h1>

          { pnAndDate }

          { description }

          <a href={ this.props.recordLink } className="card-showfull">
            See Full Record
          </a>
        </div>
      )
    }
  }
}
