require_relative '../../app/models/series_list'

describe SeriesList do
  def h(n)
    # just an abbreviation to keep the tests readable
    { online: n, all: nil }
  end
  it 'does basic grouping and sorting' do
    grouped = SeriesList.new({ 'MOUSE' => 1,
                               'cat' => 1,
                               'moose' => 1,
                               'dog' => 1,
                               'mousse' => 100 }, {}).by_first_letter
    expect(grouped).to eq([
      ['C', [['cat', h(1)]]],
      ['D', [['dog', h(1)]]],
      ['M', [['moose', h(1)], ['MOUSE', h(1)], ['mousse', h(100)]]]
    ])
  end

  it 'handles articles' do
    grouped = SeriesList.new({ 'An A' => 1,
                               'A B' => 2,
                               'The C' => 3,
                               'the D' => 4,
                               'THE E' => 5,
                               'able' => 1,
                               'baker' => 2,
                               'charlie' => 3,
                               'delta' => 4,
                               'easy' => 5 }, {}).by_first_letter
    expect(grouped).to eq([
      ['A', [['An A', h(1)], ['able', h(1)]]],
      ['B', [['A B', h(2)], ['baker', h(2)]]],
      ['C', [['The C', h(3)], ['charlie', h(3)]]],
      ['D', [['the D', h(4)], ['delta', h(4)]]],
      ['E', [['THE E', h(5)], ['easy', h(5)]]]
    ])
  end

  it 'handles for digits and other' do
    grouped = SeriesList.new({ '¿Que pasa?' => 1,
                               '3-2-1 Contact' => 2,
                               ' evil whitespace' => 3,
                               'wimpy' => 0,
                               'xerox' => 1,
                               'a yuppie' => 2,
                               'the zebra' => 3 }, {}).by_first_letter
    expect(grouped).to eq([
      ['E', [[' evil whitespace', h(3)]]],
      ['W', [['wimpy', h(0)]]],
      ['XYZ', [['xerox', h(1)], ['a yuppie', h(2)], ['the zebra', h(3)]]],
      ['other', [['3-2-1 Contact', h(2)], ['¿Que pasa?', h(1)]]]
    ])
  end
end
