require 'redirect_map'

describe RedirectMap do

  let(:redirect_map) { RedirectMap.instance }

  describe 'load' do
    it 'loads a redirect map from a YAML file' do
      expect{ redirect_map.load('./spec/fixtures/redirect_map/redirects.yml') }.to change{ redirect_map.redirects.size }.from(0).to(2)
    end

    it 'raises an error if the YAML file does not evaluate to a hash' do
      expect{ redirect_map.load('./spec/fixtures/redirect_map/invalid_redirects_1.yml') }.to raise_error RedirectMap::InvalidRedirectMapFile
    end

    it 'raises an error if it is not a YAML file' do
      expect{ redirect_map.load('./spec/fixtures/redirect_map/invalid_redirects_2.txt') }.to raise_error RedirectMap::InvalidRedirectMapFile
    end
  end

  describe 'lookup' do

    before { redirect_map.load './spec/fixtures/redirect_map/redirects.yml' }

    it 'returns nil when not found' do
      expect(redirect_map.lookup('not-in-the-map')).to be_nil
    end

    it 'returns the appropriate redirect if found' do
      expect(redirect_map.lookup('/foo')).to eq '/bar'
      expect(redirect_map.lookup('/old/and/stinky')).to eq '/new/and/shiny'
    end
  end
end