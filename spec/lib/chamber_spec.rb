require 'rspectacular'
require 'chamber'
require 'tempfile'

class Settings
  extend Chamber
end

describe Chamber do
  before do
    Settings.clear!
  end

  describe '.source' do
    context 'when an invalid option is specified' do
      let(:options) do
        { foo: 'bar' }
      end

      it 'raises ChamberInvalidOptionError' do
        expect { Settings.source('filename', options) }.to raise_error(Chamber::ChamberInvalidOptionError)
      end
    end

    context 'when no options are specified' do
      it 'does not raise an error' do
        expect { Settings.source('filename') }.not_to raise_error
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
  end

  describe '.load!' do
    context 'when a non-existent file is specified' do
      let(:file) { Tempfile.new('test') }
      let!(:filename) { file.path }

      before do
        file.close
        file.unlink
        expect(File.exists?(filename)).to be_false
        Settings.source filename
      end

      it 'does not raise an error' do
        expect { Settings.load! }.not_to raise_error
      end

      it 'leaves the instance empty' do
        Settings.load!
        expect(Settings.instance).to be_empty
      end
    end

    context 'when an existing file is specified' do
      let(:file) { Tempfile.new('test') }
      let(:filename) { file.path }
      let(:content) do
        <<-CONTENT
secret:
  environment: CHAMBER_TEST
development:
  foo: bar dev
test:
  foo: bar test
CONTENT
      end

      before do
        file.write(content)
        file.close
      end

      after do
        file.unlink
      end

      context 'and no options are specified' do
        before { Settings.source(filename) }

        let(:expected) do
          {
            'secret' => {
              'environment' => 'CHAMBER_TEST'
            },
            'development' => {
              'foo' => 'bar dev'
            },
            'test' => {
              'foo' => 'bar test'
            }
          }
        end

        it 'loads all settings' do
          Settings.load!
          expect(Settings.instance.to_hash).to eq expected
        end

        it 'provides access to all settings without the instance root' do
          Settings.load!
          expect(Settings.to_hash).to eq expected
        end
      end

      context 'and the :namespace option is specified' do
        before { Settings.source(filename, namespace: namespace) }

        context 'and it is valid' do
          let(:namespace) { 'development' }
          let(:expected) do
            {
              'foo' => 'bar dev'
            }
          end

          it 'loads settings for the specified namespace' do
            Settings.load!
            expect(Settings.instance.to_hash).to eq expected
          end

          it 'provides access to all settings without the instance root' do
            Settings.load!
            expect(Settings.to_hash).to eq expected
          end
        end

        context 'and it is not valid' do
          let(:namespace) { 'staging' }

          it 'raises a KeyError' do
            expect { Settings.load! }.to raise_error(KeyError)
          end
        end
      end

      context 'and the :override_from_environment option is specified' do
        before { Settings.source(filename, override_from_environment: true) }

        context 'and the environment variable is present' do
          before { ENV['CHAMBER_TEST'] = 'value' }

          it 'overrides the settings from the environment' do
            Settings.load!
            expect(Settings.instance.secret).to eq 'value'
          end

          it 'provides access to all settings without the instance root' do
            Settings.load!
            expect(Settings.secret).to eq 'value'
          end
        end

        context 'and the environment variable is not present' do
          before { ENV.delete('CHAMBER_TEST') }

          it 'sets the value to nil' do
            Settings.load!
            expect(Settings.instance.secret).to be_nil
          end

          it 'provides acccess to all settings without the instance root' do
            Settings.load!
            expect(Settings.secret).to be_nil
          end
        end
      end
    end
  end

  describe '.reload!' do
    context 'when a filename is changed after it is sourced and loaded' do
      let(:file) { Tempfile.new('test') }
      let!(:filename) { file.path }
      let(:content) do
        <<-CONTENT
initial: value
CONTENT
      end
      let(:modified) do
        <<-MODIFIED
modified: changed
MODIFIED
      end

      before do
        file.write(content)
        file.close
        Settings.source(filename)
        Settings.load!
      end

      after do
        file.unlink
      end

      it 'reloads the settings' do
        File.open(filename, 'w') { |writer| writer.write(modified) }

        expect { Settings.reload! }.to change { Settings.instance.to_hash }.from({ 'initial' => 'value' }).to({ 'modified' => 'changed' })
      end
    end
  end

  describe '.instance' do
    it 'is a Hashie::Mash' do
      expect(Settings.instance).to be_a(Hashie::Mash)
    end
  end

  describe '.env' do
    it 'is aliased to :instance' do
      expect(Settings.method(:env)).to eq Settings.method(:instance)
    end
  end
end
