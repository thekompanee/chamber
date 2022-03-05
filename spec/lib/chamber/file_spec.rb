# frozen_string_literal: true

require 'rspectacular'
require 'securerandom'
require 'chamber/file'
require 'chamber/settings'
require 'chamber/filters/encryption_filter'
require 'tempfile'

# rubocop:disable Layout/LineLength
class ChamberTest
  def create_tempfile(content)
    tempfile = Tempfile.new('settings')
    tempfile.puts content
    tempfile.rewind
    tempfile
  end
end

module    Chamber
describe  File do
  let(:test) { ::ChamberTest.new }

  it 'can convert file contents to settings' do
    tempfile      = test.create_tempfile '{ test: settings }'
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new)
                         .and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  be :settings
    expect(Settings).to       have_received(:new)
                                .with(settings:        { 'test' => 'settings' },
                                      namespaces:      {},
                                      decryption_keys: {},
                                      encryption_keys: {})
  end

  it 'can convert a file whose contents are empty' do
    tempfile      = test.create_tempfile ''
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new)
                         .and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  be :settings
    expect(Settings).to       have_received(:new)
                                .with(settings:        {},
                                      namespaces:      {},
                                      decryption_keys: {},
                                      encryption_keys: {})
  end

  it 'throws an error when the file contents are malformed' do
    tempfile      = test.create_tempfile '{ test : '
    settings_file = File.new path: tempfile.path

    expect { settings_file.to_settings }
      .to raise_error(Psych::SyntaxError)
  end

  it 'passes any namespaces through to the settings' do
    tempfile      = test.create_tempfile '{ test: settings }'
    settings_file = File.new  path:       tempfile.path,
                              namespaces: {
                                environment: :development,
                              }

    allow(Settings).to receive(:new)

    settings_file.to_settings

    expect(Settings).to have_received(:new)
                          .with(settings:        { 'test' => 'settings' },
                                namespaces:      {
                                  environment: :development,
                                },
                                decryption_keys: {},
                                encryption_keys: {})
  end

  it 'can handle files which contain ERB markup' do
    tempfile      = test.create_tempfile '{ test: <%= 1 + 1 %> }'
    settings_file = File.new path: tempfile.path

    allow(Settings).to receive(:new)

    settings_file.to_settings
    expect(Settings).to have_received(:new)
                          .with(settings:        { 'test' => 2 },
                                namespaces:      {},
                                decryption_keys: {},
                                encryption_keys: {})
  end

  it 'does not throw an error when attempting to convert a file which does not exist' do
    settings_file = File.new path: 'no/path'

    allow(Settings).to receive(:new)
                         .and_return :settings

    file_settings = settings_file.to_settings

    expect(file_settings).to  be :settings
    expect(Settings).to       have_received(:new)
                                .with(settings:        {},
                                      namespaces:      {},
                                      decryption_keys: {},
                                      encryption_keys: {})
  end

  it 'can securely encrypt the settings contained in a file' do
    tempfile = test.create_tempfile <<-HEREDOC
_secure_setting: hello
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    settings_file = File.new path: tempfile.path

    expect(settings_file.to_settings.__send__(:raw_data)['_secure_setting']).to match Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'does not encrypt the settings contained in a file which are already secure' do
    tempfile = test.create_tempfile <<-HEREDOC
_secure_setting: hello
_secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    settings_file        = File.new path: tempfile.path
    raw_data             = settings_file.to_settings.__send__(:raw_data)
    secure_setting       = raw_data['_secure_setting']
    other_secure_setting = raw_data['_secure_other_setting']

    expect(secure_setting).to       match Filters::EncryptionFilter::BASE64_STRING_PATTERN
    expect(other_secure_setting).to eql   'g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBU' \
                                          'KlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPO' \
                                          'aDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6Rrm' \
                                          'ydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+' \
                                          'eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpIN' \
                                          'A6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8' \
                                          'uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x' \
                                          '+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw=='
  end

  it 'does not rewrite the entire file but only the encrypted settings' do
    tempfile = test.create_tempfile <<-HEREDOC
defaults:
  stuff: &defaults
    _secure_setting:       hello
    _secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==

other:
  stuff:
    <<: *defaults
    _secure_another_setting: "Thanks for all the fish"
    regular_setting:         <%= 1 + 1 %>
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    file_contents                  = ::File.read(tempfile.path)
    secure_setting_encoded         = file_contents[%r{    _secure_setting:       ([A-Za-z0-9+/]{342}==)$}, 1]
    secure_another_setting_encoded = file_contents[%r{    _secure_another_setting: ([A-Za-z0-9+/]{342}==)$}, 1]

    expect(::File.read(tempfile.path)).to eql <<-HEREDOC
defaults:
  stuff: &defaults
    _secure_setting:       #{secure_setting_encoded}
    _secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==

other:
  stuff:
    <<: *defaults
    _secure_another_setting: #{secure_another_setting_encoded}
    regular_setting:         <%= 1 + 1 %>
    HEREDOC
  end

  it 'can handle encrypting multiline strings' do
    tempfile = test.create_tempfile <<-HEREDOC
other:
  stuff:
    _secure_setting: |
      -----BEGIN RSA PRIVATE KEY-----
      uQ431irYF7XGEwmsfNUcw++6Enjmt9MItVZJrfL4cUr84L1ccOEX9AThsxz2nkiO
      GgU+HtwwueZDUZ8Pdn71+1CdVaSUeEkVaYKYuHwYVb1spGfreHQHRP90EMv3U5Ir
      xs0YFwKBgAJKGol+GM1oFodg48v4QA6hlF5z49v83wU+AS2f3aMVfjkTYgAEAoCT
      qoSi7wkYK3NvftVgVi8Z2+1WEzp3S590UkkHmjc5o+HfS657v2fnqkekJyinB+OH
      b5tySsPxt/3Un4D9EaGhjv44GMvL54vFI1Sqc8RsF/H8lRvj5ai5
      -----END RSA PRIVATE KEY-----
    something_else:  'right here'
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    file_contents          = ::File.read(tempfile.path)
    secure_setting_encoded = file_contents[/    _secure_setting: (.*)$/, 1]

    expect(::File.read(tempfile.path)).to eql <<-HEREDOC
other:
  stuff:
    _secure_setting: #{secure_setting_encoded}
    something_else:  'right here'
    HEREDOC
  end

  it 'when rewriting the file, can handle names and values with regex special ' \
     'characters' do

    tempfile = test.create_tempfile <<-HEREDOC
stuff:
  _secure_another+_setting: "Thanks for +all the fish"
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    file_contents                  = ::File.read(tempfile.path)
    secure_another_setting_encoded = file_contents[%r{  _secure_another\+_setting: ([A-Za-z0-9+/]{342}==)$}, 1]

    expect(::File.read(tempfile.path)).to eql <<-HEREDOC
stuff:
  _secure_another+_setting: #{secure_another_setting_encoded}
    HEREDOC
  end

  it 'can generate a signature file', :time_mock do
    seed           = SecureRandom.uuid
    file_path      = "/tmp/settings-#{seed}.yml"
    signature_path = "/tmp/settings-#{seed}.sig"

    ::File.write(file_path, <<-HEREDOC, mode: 'w+')
stuff:
  another_setting: "Thanks for all the fish"
    HEREDOC

    settings_file = File.new  path:            file_path,
                              decryption_keys: { signature: './spec/spec_key' },
                              signature_name:  'Suzy Q Robinson'

    settings_file.sign

    expect(::File.read(signature_path)).to eql <<-HEREDOC
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
qGBhOsEkkwiTJYh8BVWOMekYReR42GI8E+Rpj5TCNlU+VN3H3YhKx1fueKIzGKP0Vjdraeg3vn5UwlBtJrVSp9iNRewXtuADF1RlkZ5ZRaRDs6/H+71KuPY7fPYdx47u0oVgSv5hEH3QehdAVA/Qh4rjoOg0IieJGcstckY/ADerNefraAVJ69sJc0ZaylSWxLDFDp4lHM4ytDHoWPTxSVT3KTAwjaxgc37LE+rhjOuOnsEJYwmyevAUW9sk7OBN4p8vn92Fsq7/SbKSFNIi/+HUOOF+yAinijQoUSfnByMBUoS5b4k4dHxadVEn9QDDtflQ5/Aosjb0718v7/tBhw==
-----END CHAMBER SIGNATURE-----
    HEREDOC
  end

  it 'fails signing if there are no signature keys available' do
    seed      = SecureRandom.uuid
    file_path = "/tmp/settings-#{seed}.yml"

    ::File.write(file_path, <<-HEREDOC, mode: 'w+')
stuff:
  another_setting: "Thanks for all the fish"
    HEREDOC

    settings_file = File.new  path:            file_path,
                              decryption_keys: { foo: './spec/spec_key' }

    expect { settings_file.sign }
      .to \
        raise_error(ArgumentError)
          .with_message('You asked to sign your settings files but no signature key was found.  Run `chamber init --signature` to generate one.')
  end

  it 'can verify a signature file', :time_mock do
    seed           = SecureRandom.uuid
    file_path      = "/tmp/settings-#{seed}.yml"
    signature_path = "/tmp/settings-#{seed}.sig"

    ::File.write(file_path, <<-HEREDOC, mode: 'w+')
stuff:
  another_setting: "Thanks for all the fish"
    HEREDOC

    ::File.write(signature_path, <<-HEREDOC, mode: 'w+')
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
qGBhOsEkkwiTJYh8BVWOMekYReR42GI8E+Rpj5TCNlU+VN3H3YhKx1fueKIzGKP0Vjdraeg3vn5UwlBtJrVSp9iNRewXtuADF1RlkZ5ZRaRDs6/H+71KuPY7fPYdx47u0oVgSv5hEH3QehdAVA/Qh4rjoOg0IieJGcstckY/ADerNefraAVJ69sJc0ZaylSWxLDFDp4lHM4ytDHoWPTxSVT3KTAwjaxgc37LE+rhjOuOnsEJYwmyevAUW9sk7OBN4p8vn92Fsq7/SbKSFNIi/+HUOOF+yAinijQoUSfnByMBUoS5b4k4dHxadVEn9QDDtflQ5/Aosjb0718v7/tBhw==
-----END CHAMBER SIGNATURE-----
    HEREDOC

    settings_file = File.new  path:            file_path,
                              encryption_keys: { signature: './spec/spec_key.pub' }

    expect(settings_file.verify).to be true
  end

  it 'fails verifying if there are no signature keys available' do
    seed      = SecureRandom.uuid
    file_path = "/tmp/settings-#{seed}.yml"

    ::File.write(file_path, <<-HEREDOC, mode: 'w+')
stuff:
  another_setting: "Thanks for all the fish"
    HEREDOC

    settings_file = File.new  path:            file_path,
                              encryption_keys: { foo: './spec/spec_key.pub' }

    expect { settings_file.verify }
      .to \
        raise_error(ArgumentError)
          .with_message('You asked to verify your settings files but no signature key was found.  Run `chamber init --signature` to generate one.')
  end
end
end
# rubocop:enable Layout/LineLength
