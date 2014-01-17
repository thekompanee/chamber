require 'rspectacular'
require 'chamber/commands/secure'
require 'fileutils'

module    Chamber
module    Commands
describe  Secure do
  let(:rootpath)          { Pathname.new(::File.expand_path('./spec/fixtures')) }
  let(:settings_filename) { rootpath + 'settings' + 'unencrypted.yml' }
  let(:options)           { {  basepath:       rootpath,
                               rootpath:       rootpath,
                               encryption_key: rootpath + '../spec_key'} }

  it 'can return values formatted as environment variables' do
    ::FileUtils.mkdir_p rootpath + 'settings' unless ::File.exist? rootpath + 'settings'
    ::File.open(settings_filename, 'w') do |file|
      file.write <<-HEREDOC
test:
  _secure_my_unencrpyted_setting: hello
HEREDOC
    end

    files = Secure.call(options)

    expect(::File.read(settings_filename)).to match %r{_secure_my_unencrpyted_setting: [A-Za-z0-9\+\/]{342}==}

    ::File.delete(settings_filename)
  end
end
end
end
