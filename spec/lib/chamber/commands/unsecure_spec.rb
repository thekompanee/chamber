# frozen_string_literal: true

require 'rspectacular'
require 'chamber/commands/unsecure'
require 'fileutils'

module    Chamber
module    Commands
describe  Unsecure do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:rootpath)           { Pathname.new(::File.expand_path('./spec/fixtures')) }
  let(:settings_directory) { rootpath + 'settings' }
  let(:settings_filename)  { settings_directory + 'encrypted.yml' }
  let(:options)            do
    {
      basepath:        rootpath,
      rootpath:        rootpath,
      decryption_keys: rootpath + '../spec_key',
      shell:           double.as_null_object, # rubocop:disable RSpec/VerifiedDoubles
    }
  end

  before(:each) do
    ::FileUtils.mkdir_p settings_directory unless ::File.exist? settings_directory
  end

  after(:each) do
    ::FileUtils.rm_rf(settings_directory) if ::File.exist? settings_directory
  end

  it 'can return values formatted as environment variables' do
    settings_filename.write <<~HEREDOC
      test:
        _secure_my_encrypted_setting:   YDCCivOY8rcqYmM7OMzqSQL3hRZlySGVklad7Ouk3a4r4aJk4nLa/u+vE316CNvtJF5uP+FJ6lCf4s5w4hd9/hmdgzZQ+CVGgzB3iSP4IqZuL+hsLW994BuUSk3iv1X2Bv1t/3I5BOLtbgMeZrgzUFjWYEbPcfCi09RrbXFYekiAghP6tPybcPp6yTc8sS3cVty4cAcjfKB3POZQ95htyqtM97sQ78wtJcftCBz/9XkT9aFHtOicXwurV4uaSan6LBV5D419/a/Aqij2PMe6FJ+65Xo1wf6V61AIqg9600M28r5/36tYwVEJdk0x4ka2Ijs3JeOcwN8cekemx/2lsA==
        _secure_my_unencrypted_setting: goodbye
    HEREDOC

    Unsecure.call(**options)

    expect(settings_filename.read)
      .to eql <<~HEREDOC
        test:
          _secure_my_encrypted_setting:   hello
          _secure_my_unencrypted_setting: goodbye
      HEREDOC
  end
end
end
end
