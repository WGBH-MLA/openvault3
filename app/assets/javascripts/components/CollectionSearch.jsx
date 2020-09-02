class CollectionSearch extends React.Component {
  render() {
    let classes = 'card-container '
    classes += this.props.expanded == this.props.index ? ' expanded' : ''
    let sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}
    return (
      <div id="treasury-search">
        <input value={ this.props.search } placeholder="Search..." type="text" onChange={ this.props.handleOnChange } />
        <button onClick={ this.props.clearSearch }></button>
      </div>
    )
  }
}
