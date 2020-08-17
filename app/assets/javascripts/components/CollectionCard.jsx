class CollectionCard extends React.Component {
  render() {
    let classes = 'card-container '
    classes += this.props.expanded == this.props.index ? ' expanded' : ''

    return (
      <div onClick={ () => this.props.expand(this.props.index) } className={ classes }>
        <div className="card-container-mask"></div>

        <h1 className="card-title">
          { this.props.title }
        </h1>

        <div className="card-description">
          { this.props.description }
        </div>

        <a href={ this.props.record_link } className="card-showfull">
          See Full Record
        </a>
      </div>
    )
  }
}