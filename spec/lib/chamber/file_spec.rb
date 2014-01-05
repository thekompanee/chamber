require 'rspectacular'
require 'chamber/file'
require 'chamber/settings'
require 'tempfile'

def create_tempfile_with_content(content)
  tempfile = Tempfile.new('settings')
  tempfile.puts content
  tempfile.rewind
  tempfile
end

class     Chamber
describe  File do
  it 'can convert file contents to settings' do
    tempfile      = create_tempfile_with_content %Q({ test: settings })
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:    {'test' => 'settings'},
                                   namespaces:  {})
  end

  it 'can convert a file whose contents are empty' do
    tempfile      = create_tempfile_with_content ''
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:    {},
                                   namespaces:  {})
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
                                environment:  :development })
  end

  it 'can handle files which contain ERB markup' do
    tempfile      = create_tempfile_with_content %Q({ test: <%= 1 + 1 %> })
    settings_file = File.new  path: tempfile.path

    allow(Settings).to      receive(:new)

    settings_file.to_settings
    expect(Settings).to have_received(:new).
                        with( settings:   {'test' => 2},
                              namespaces: {} )
  end

  it 'does not throw an error when attempting to convert a file which does not exist' do
    settings_file = File.new path: 'no/path'

    allow(Settings).to receive(:new).
                       and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  eql :settings
    expect(Settings).to       have_received(:new).
                              with(settings:    {},
                                   namespaces:  {})
  end
end
end
