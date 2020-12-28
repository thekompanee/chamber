# frozen_string_literal: true

require 'rspectacular'
require 'securerandom'
require 'fileutils'
require 'chamber/commands/sign'

module    Chamber
module    Commands
describe  Sign do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:rootpath)           { Pathname.new(::File.expand_path("./tmp/fixtures-#{SecureRandom.uuid}")) }
  let(:settings_directory) { rootpath + 'settings' }
  let(:settings_filename)  { settings_directory + 'settings.yml' }
  let(:signature_filename) { settings_directory + 'settings.sig' }
  let(:options)            do
    {
      basepath:        rootpath,
      rootpath:        rootpath,
      decryption_keys: rootpath + '../../spec/fixtures/keys/real/.chamber.signature.pem',
      shell:           double.as_null_object, # rubocop:disable RSpec/VerifiedDoubles
      signature_name:  'Suzy Q Robinson',
    }
  end

  before(:each) do
    ::FileUtils.mkdir_p settings_directory unless ::File.exist? settings_directory
  end

  after(:each) do
    ::FileUtils.rm_rf(settings_directory) if ::File.exist? settings_directory
  end

  it 'can generate signature files', :time_mock do
    settings_filename.write <<-HEREDOC
test:
  my_setting: hello
    HEREDOC

    Sign.call(options)

    expect(signature_filename.read).to eql(<<-HEREDOC)
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
QhGPAea/1RQZnh8ES+Esmr3ZssBtZJvxp+yW7wUMHc2D5Mq9SzLymuwSxLtOGuJsqlxMWW0FaOIK1F0AcQRnw9+RXfdGvBNsm/5LJr1TYJ9EfAKFY/PPDpnMId6gJV/Tz+y5sOt97oyUXVqDbd6jbwmJvYWNfYYTmI1NunkRRNtLuS83hce+qJLPhmYqnHEkWvbcczkjml/axfh5l5VS8aob9zfXnHryMoaCu2E/yfZOsXDEXVLVAGid33eq719Wm/nK2R4hhgRMrm7+4kfGSQyluOAobgvU3jspKJZO7tLH3uXYxqTVG9ZldEc8tRlP79QjSwJdWLoLmwL+bnAjIQ==
-----END CHAMBER SIGNATURE-----
    HEREDOC
  end
end
end
end
