require_relative '../../app/models/series_list'

describe SeriesList do
  it 'does basic grouping and sorting' do
    grouped = SeriesList.new({
        'mouse' => 100,
        'cat' => 10,
        'dog' => 1
      }).by_first_letter
    expect(grouped).to eq([
      ['C', [['cat', 10]]],
      ['D', [['dog', 1]]],
      ['M', [['mouse', 100]]]
    ])
  end
end