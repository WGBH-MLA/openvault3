class CollectionCard extends React.Component {
  render() {
    let classes = 'card-container '
    classes += this.props.expanded == this.props.index ? ' expanded' : ''
    let sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}

    return (
      <div style={ sty } onClick={ () => this.props.expand(this.props.index) } className={ classes }>
        <div className="card-container-mask"></div>

        <h1 className="card-title">
          { this.props.title }
        </h1>

        <div className="card-description">
          { this.props.description }
        </div>

        <a href={ this.props.recordLink } className="card-showfull">
          See Full Record
        </a>
      </div>
    )
  }
}
