class CollectionSearch extends React.Component {
  render() {
    let classes = 'card-container '
    classes += this.props.expanded == this.props.index ? ' expanded' : ''
    let sty = {backgroundImage: 'url(' + this.props.cardImage + ')'}
    return (
      <div>
        <input placeholder="Search..." type="text" onChange={ this.props.handleOnChange } />
      </div>
    )
  }
}
