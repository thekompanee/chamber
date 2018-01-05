# frozen_string_literal: true

require 'rspectacular'
require 'chamber/commands/secure'
require 'fileutils'

module    Chamber
module    Commands
describe  Secure do
  let(:rootpath)           { Pathname.new(::File.expand_path('./spec/fixtures')) }
  let(:settings_directory) { rootpath + 'settings' }
  let(:settings_filename)  { settings_directory + 'unencrypted.yml' }
  let(:options)            do
    {
      basepath:        rootpath,
      rootpath:        rootpath,
      encryption_keys: rootpath + '../spec_key',
      shell:           double.as_null_object,
    }
  end

  before(:each) do
    ::FileUtils.mkdir_p settings_directory unless ::File.exist? settings_directory
  end

  after(:each) do
    ::FileUtils.rm_rf(settings_directory) if ::File.exist? settings_directory
  end

  it 'can return values formatted as environment variables' do
    settings_filename.write <<-HEREDOC
test:
  _secure_my_unencrpyted_setting: hello
HEREDOC

    Secure.call(options)

    expect(settings_filename.read).
      to match %r{_secure_my_unencrpyted_setting: [A-Za-z0-9\+\/]{342}==}
  end
end
end
end
