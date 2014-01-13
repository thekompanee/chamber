require 'rspectacular'
require 'chamber/file'
require 'chamber/settings'
require 'chamber/filters/encryption_filter'
require 'tempfile'

def create_tempfile_with_content(content)
  tempfile = Tempfile.new('settings')
  tempfile.puts content
  tempfile.rewind
  tempfile
end

module    Chamber
describe  File do
  it 'can convert file contents to settings' do
    tempfile      = create_tempfile_with_content %Q({ test: settings })
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:       {'test' => 'settings'},
                                   namespaces:     {},
                                   decryption_key: nil,
                                   encryption_key: nil)
  end

  it 'can convert a file whose contents are empty' do
    tempfile      = create_tempfile_with_content ''
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:       {},
                                   namespaces:     {},
                                   decryption_key: nil,
                                   encryption_key: nil)
  end

  it 'throws an error when the file contents are malformed' do
    tempfile      = create_tempfile_with_content %Q({ test : )
    settings_file = File.new path: tempfile.path

    expect { settings_file.to_settings }.to raise_error
  end

  it 'passes any namespaces through to the settings' do
    tempfile      = create_tempfile_with_content %Q({ test: settings })
    settings_file = File.new  path:       tempfile.path,
                              namespaces: {
                                environment:  :development }

    allow(Settings).to  receive(:new)

    settings_file.to_settings

    expect(Settings).to have_received(:new).
                        with( settings:    {'test' => 'settings'},
                              namespaces: {
                                environment:  :development },
                              decryption_key: nil,
                              encryption_key: nil)
  end

  it 'can handle files which contain ERB markup' do
    tempfile      = create_tempfile_with_content %Q({ test: <%= 1 + 1 %> })
    settings_file = File.new  path: tempfile.path

    allow(Settings).to      receive(:new)

    settings_file.to_settings
    expect(Settings).to have_received(:new).
                        with( settings:   {'test' => 2},
                              namespaces: {},
                              decryption_key: nil,
                              encryption_key: nil)
  end

  it 'does not throw an error when attempting to convert a file which does not exist' do
    settings_file = File.new path: 'no/path'

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:       {},
                                   namespaces:     {},
                                   decryption_key: nil,
                                   encryption_key: nil)
  end

  it 'can securely encrypt the settings contained in a file' do
    tempfile      = create_tempfile_with_content %Q({ _secure_setting: hello })
    settings_file = File.new  path:           tempfile.path,
                              encryption_key: './spec/spec_key.pub'

    settings_file.secure

    settings_file = File.new  path:           tempfile.path

    expect(settings_file.to_settings.send(:raw_data)['_secure_setting']).to match Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end
end
end
