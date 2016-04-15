require_relative '../../lib/transcripter'

describe Transcripter do
  describe '#from_tei' do
    it 'produces HTML' do
      tei = File.read(__dir__ + '/../fixtures/transcript/mock-transcript.xml')
      expect(Transcripter.from_tei(tei)).to eq(File.read(__dir__ + '/../fixtures/transcript/mock-transcript.html'))
    end
  end
end
