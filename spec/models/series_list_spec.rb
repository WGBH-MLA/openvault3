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
end