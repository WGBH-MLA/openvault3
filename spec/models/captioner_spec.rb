require_relative '../../lib/captioner'

describe Captioner do
  it 'produces WebVTT' do
    tei = File.read(__dir__ + '/../fixtures/transcript/mock-transcript.xml')
    expect(Captioner.from_tei(tei)).to eq(File.read(__dir__ + '/../fixtures/transcript/mock-transcript.vtt'))
  end
end
