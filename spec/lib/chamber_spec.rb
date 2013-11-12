require 'spec_helper'

require 'tempfile'

class Settings
  extend Chamber
end

describe Chamber do
  describe '.source' do
    context 'when an invalid option is specified' do
      let(:options) do
        { foo: 'bar' }
      end

      it 'raises ChamberInvalidOptionError' do
        expect { Settings.source('filename', options) }.to raise_error(Chamber::ChamberInvalidOptionError)
      end
    end

    context 'when valid options are specified' do
      context 'and options only contains :namespace' do
        let(:options) do
          { namespace: 'bar' }
        end

        it 'does not raise an error' do
          expect { Settings.source('filename', options) }.not_to raise_error
        end
      end

      context 'and options only contains :override_from_environment' do
        let(:options) do
          { override_from_environment: 'bar' }
        end

        it 'does not raise an error' do
          expect { Settings.source('filename', options) }.not_to raise_error
        end
      end

      context 'and options contains both :namespace and :override_from_environment' do
        let(:options) do
          {
            namespace: 'bar',
            override_from_environment: 'bar'
          }
        end

        it 'does not raise an error' do
          expect { Settings.source('filename', options) }.not_to raise_error
        end
      end
    end

    context 'when a non-existent file is specified' do
      let(:file) { Tempfile.new('test') }
      let!(:filename) { file.path }

      before do
        file.close
        file.unlink
        expect(File.exists?(filename)).to be_false
        Settings.source filename
      end

      it 'does not raise an error when loading' do
        expect { Settings.load! }.not_to raise_error
      end

      it 'does not change the instance when loading' do
        expect { Settings.load! }.not_to change { Settings.instance }
      end

      it 'leaves the instance empty after loading' do
        Settings.load!
        expect(Settings.instance).to be_empty
      end
    end
  end

  describe '.instance' do
    it 'is a Hashie::Mash' do
      expect(Settings.instance).to be_a(Hashie::Mash)
    end
  end
end
