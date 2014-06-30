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
    tempfile      = create_tempfile_with_content <<-HEREDOC
_secure_setting: hello
HEREDOC
    settings_file = File.new  path:           tempfile.path,
                              encryption_key: './spec/spec_key.pub'

    settings_file.secure

    settings_file = File.new  path:           tempfile.path

    expect(settings_file.to_settings.send(:raw_data)['_secure_setting']).to match Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'does not encrypt the settings contained in a file which are already secure' do
    tempfile      = create_tempfile_with_content <<-HEREDOC
_secure_setting: hello
_secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==
HEREDOC

    settings_file = File.new  path:           tempfile.path,
                              encryption_key: './spec/spec_key.pub'

    settings_file.secure

    settings_file = File.new  path:           tempfile.path

    expect(settings_file.to_settings.send(:raw_data)['_secure_setting']).to       match Filters::EncryptionFilter::BASE64_STRING_PATTERN
    expect(settings_file.to_settings.send(:raw_data)['_secure_other_setting']).to eql   "g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw=="
  end

  it 'does not rewrite the entire file but only the encrypted settings' do
    tempfile      = create_tempfile_with_content <<-HEREDOC
default:
  stuff: &default
    _secure_setting:       hello
    _secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==

other:
  stuff:
    <<: *default
    _secure_another_setting: "Thanks for all the fish"
    regular_setting:         <%= 1 + 1 %>
HEREDOC

    settings_file = File.new  path:           tempfile.path,
                              encryption_key: './spec/spec_key.pub'

    settings_file.secure

    file_contents                  = ::File.read(tempfile.path)
    secure_setting_encoded         = file_contents[/    _secure_setting:       ([A-Za-z0-9\+\/]{342}==)$/, 1]
    secure_another_setting_encoded = file_contents[/    _secure_another_setting: ([A-Za-z0-9\+\/]{342}==)$/, 1]

    expect(::File.read(tempfile.path)).to eql <<-HEREDOC
default:
  stuff: &default
    _secure_setting:       #{secure_setting_encoded}
    _secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==

other:
  stuff:
    <<: *default
    _secure_another_setting: #{secure_another_setting_encoded}
    regular_setting:         <%= 1 + 1 %>
HEREDOC
  end
end
end
