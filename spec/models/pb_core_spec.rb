require_relative '../../app/models/validated_pb_core'

describe 'Validated and plain PBCore' do
  pbc_xml = File.read('spec/fixtures/pbcore/mock.xml')

  describe ValidatedPBCore do
    describe 'valid docs' do
      Dir['spec/fixtures/pbcore/*.xml'].each do |path|
        it "accepts #{File.basename(path)}" do
          expect { ValidatedPBCore.new(File.read(path)) }.not_to raise_error
        end
      end
    end

    describe 'invalid docs' do
#      it 'rejects missing closing brace' do
#        invalid_pbcore = pbc_xml.sub(/>\s*$/, '')
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/missing tag start/))
#      end

      it 'rejects missing closing tag' do
        invalid_pbcore = pbc_xml.sub(/<\/[^>]+>\s*$/, '')
        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
          raise_error(/Missing end tag/))
      end

      it 'rejects missing namespace' do
        invalid_pbcore = pbc_xml.sub(/xmlns=['"][^'"]+['"]/, '')
        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
          raise_error(/Element 'pbcoreDescriptionDocument': No matching global declaration/))
      end

#      it 'rejects unknown media types at creation' do
#        invalid_pbcore = pbc_xml.gsub(
#          /<instantiationMediaType>[^<]+<\/instantiationMediaType>/,
#          '<instantiationMediaType>unexpected</instantiationMediaType>')
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/Unexpected media types: \["unexpected"\]/))
#      end

#      it 'rejects multi "Level of User Access"' do
#        invalid_pbcore = pbc_xml.sub(
#          /<pbcoreAnnotation/,
#          "<pbcoreAnnotation annotationType='Level of User Access'>On Location</pbcoreAnnotation><pbcoreAnnotation")
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/Should have at most 1 "Level of User Access" annotation/))
#      end

#      it 'rejects digitized w/o "Level of User Access"' do
#        invalid_pbcore = pbc_xml.gsub(
#          /<pbcoreAnnotation annotationType='Level of User Access'>[^<]+<[^>]+>/,
#          '')
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/Should have "Level of User Access" annotation if digitized/))
#      end

#      it 'rejects undigitized w/ "Level of User Access"' do
#        invalid_pbcore = pbc_xml.gsub(
#          /<pbcoreIdentifier source='Sony Ci'>[^<]+<[^>]+>/,
#          '')
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/Should not have "Level of User Access" annotation if not digitized/))
#      end

#      it 'rejects "Outside URL" if not explicitly ORR' do
#        invalid_pbcore = pbc_xml.gsub( # First make it un-digitized
#          /<pbcoreIdentifier source='Sony Ci'>[^<]+<[^>]+>/,
#          '').gsub( # Then remove access
#            /<pbcoreAnnotation annotationType='Level of User Access'>[^<]+<[^>]+>/,
#            '')
#        expect { ValidatedPBCore.new(invalid_pbcore) }.to(
#          raise_error(/If there is an Outside URL, the record must be explicitly public/))
#      end
    end
  end

  describe PBCore do
    
    describe 'full' do
      assertions = {
        series_title: 'SERIES',
        program_title: 'PROGRAM',
        program_number: 'PROGRAM-NUMBER',
        item_title: 'ITEM',
      }

      pbc = PBCore.new(pbc_xml)

      assertions.each do |method, value|
        it "\##{method} method works" do
          expect(pbc.send(method)).to eq(value)
        end
      end

#      it 'tests everthing' do
#        expect(assertions.keys.sort).to eq(PBCore.instance_methods(false).sort)
#      end
    end
  end
end
