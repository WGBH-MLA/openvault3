require 'rails_helper'

describe Tabbed do
  describe '#shared_prefix' do
    it 'finds the longest common tokenized prefix' do
      expect(Tabbed.shared_prefix(['A B C', 'A B Z'])).to eq 'A B '
    end
    it 'must be a prefix, and not the whole string' do
      expect(Tabbed.shared_prefix(['A B C', 'A B', 'A B C D'])).to eq 'A '
    end
    it 'is sensitive to whitespace' do # but that could change, if need be
      expect(Tabbed.shared_prefix(['A B  C', 'A B C'])).to eq 'A '
    end
    it 'does not break up words' do
      expect(Tabbed.shared_prefix(['A-B-C', 'A-B-Z'])).to eq ''
    end
  end
end
