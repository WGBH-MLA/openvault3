require_relative '../../app/models/series_list'

describe SeriesList do
  it 'does basic grouping and sorting' do
    grouped = SeriesList.new({
        'MOUSE' => 1,
        'cat' => 1,
        'moose' => 1,
        'dog' => 1,
        'mousse' => 100
      }).by_first_letter
    expect(grouped).to eq([
      ['C', [['cat', 1]]],
      ['D', [['dog', 1]]],
      ['M', [['moose', 1],['MOUSE', 1],['mousse', 100]]]
    ])
  end
  
  it 'handles articles' do
    grouped = SeriesList.new({
        'An A' => 1,
        'A B' => 2,
        'The C' => 3,
        'the D' => 4,
        'THE E' => 5,
        'able' => 1,
        'baker' => 2,
        'charlie' => 3,
        'delta' => 4,
        'easy' => 5
      }).by_first_letter
    expect(grouped).to eq([
      ['A', [['An A', 1],['able', 1]]],
      ['B', [['A B', 2],['baker', 2]]],
      ['C', [['The C', 3],['charlie', 3]]],
      ['D', [['the D', 4],['delta', 4]]],
      ['E', [['THE E', 5],['easy', 5]]]
    ])
  end
  
  it 'handles for digits and other' do
    grouped = SeriesList.new({
        '¿Que pasa?' => 1,
        '3-2-1 Contact' => 2,
        ' evil whitespace' => 3,
        'wimpy' => 0,
        'xerox' => 1,
        'a yuppie' => 2,
        'the zebra' => 3,
      }).by_first_letter
    expect(grouped).to eq([
      ["E", [[" evil whitespace", 3]]], 
      ["W", [["wimpy", 0]]], 
      ["XYZ", [["xerox", 1], ["a yuppie", 2], ["the zebra", 3]]], 
      ["other", [["3-2-1 Contact", 2], ["¿Que pasa?", 1]]]
    ])
  end
end