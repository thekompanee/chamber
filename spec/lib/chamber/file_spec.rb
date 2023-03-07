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
    tempfile = test.create_tempfile <<~HEREDOC
      _secure_setting: hello
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    settings_file = File.new path: tempfile.path

    expect(settings_file.to_settings.__send__(:raw_data)['_secure_setting']).to match Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'does not encrypt the settings contained in a file which are already secure' do
    tempfile = test.create_tempfile <<~HEREDOC
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

  it 'does not rewrite the entire file but only the settings that need securing' do
    tempfile = test.create_tempfile <<~HEREDOC
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

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
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
    tempfile = test.create_tempfile <<~HEREDOC
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

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
      other:
        stuff:
          _secure_setting: #{secure_setting_encoded}
          something_else:  'right here'
    HEREDOC
  end

  it 'when encrypting the settings, can handle names and values with regex special ' \
     'characters' do

    tempfile = test.create_tempfile <<~HEREDOC
      stuff:
        _secure_another+_setting: "Thanks for +all the fish"
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              encryption_keys: { __default: './spec/spec_key.pub' }

    settings_file.secure

    file_contents                  = ::File.read(tempfile.path)
    secure_another_setting_encoded = file_contents[%r{  _secure_another\+_setting: ([A-Za-z0-9+/]{342}==)$}, 1]

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
      stuff:
        _secure_another+_setting: #{secure_another_setting_encoded}
    HEREDOC
  end

  it 'can decrypt the settings contained in a file' do
    tempfile = test.create_tempfile <<~HEREDOC
      _secure_setting: YDCCivOY8rcqYmM7OMzqSQL3hRZlySGVklad7Ouk3a4r4aJk4nLa/u+vE316CNvtJF5uP+FJ6lCf4s5w4hd9/hmdgzZQ+CVGgzB3iSP4IqZuL+hsLW994BuUSk3iv1X2Bv1t/3I5BOLtbgMeZrgzUFjWYEbPcfCi09RrbXFYekiAghP6tPybcPp6yTc8sS3cVty4cAcjfKB3POZQ95htyqtM97sQ78wtJcftCBz/9XkT9aFHtOicXwurV4uaSan6LBV5D419/a/Aqij2PMe6FJ+65Xo1wf6V61AIqg9600M28r5/36tYwVEJdk0x4ka2Ijs3JeOcwN8cekemx/2lsA==
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    settings_file = File.new path: tempfile.path

    expect(settings_file.to_settings.__send__(:raw_data)['_secure_setting']).to eql 'hello'
  end

  it 'does not decrypt the settings contained in a file which are already decrypted' do
    tempfile = test.create_tempfile <<~HEREDOC
      _secure_setting: hello
      _secure_other_setting: g4ryOaWniDPht0x1pW10XWgtC7Bax2yQAM3+p9ZDMmBUKlVXgvCn8MvdvciX0126P7uuLylY7Pdbm8AnpjeaTvPOaDnDjPATkH1xpQG/HKBy+7zd67SMb3tJ3sxJNkYm6RrmydFHkDCghG37lvCnuZs1Jvd/mhpr/+thqKvtI+c/vzY+eFxM52lnoWWOgqwGCtUjb+PMbq+HjId6X8uRbpL1SpINA6WYJwvxTVK9XD/HYn67Fcqdova4dEHoqwzFfE+XVXM8uesE1DG3PFNhAzkT+mWXtBmo17i+K4wrOO06I13uDS3x+7LqoZz/Ez17SPXRJze4M/wyWfm43pnuVw==
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    settings_file        = File.new path: tempfile.path
    raw_data             = settings_file.to_settings.__send__(:raw_data)
    secure_setting       = raw_data['_secure_setting']
    other_secure_setting = raw_data['_secure_other_setting']

    expect(secure_setting).to       eql 'hello'
    expect(other_secure_setting).to eql 'goodbye'
  end

  it 'does not rewrite the entire file but only the settings that need decrypting' do
    tempfile = test.create_tempfile <<~HEREDOC
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
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
      defaults:
        stuff: &defaults
          _secure_setting:       hello
          _secure_other_setting: goodbye

      other:
        stuff:
          <<: *defaults
          _secure_another_setting: "Thanks for all the fish"
          regular_setting:         <%= 1 + 1 %>
    HEREDOC
  end

  it 'can handle decrypting multiline strings' do
    tempfile = test.create_tempfile <<~HEREDOC
      other:
        stuff:
          _secure_setting: f0kVXbiR4Q6U1lp0p83nC9+nyxz3tg3ZAwxznVjvu/872KJWvhSY4UhqVfXsIb29e63MnG2or3Hg+vzkZ8adNs3xKmgQMtvV3BpxLVzvyNnhHmPsjyUH2bw8BvOev5V8cX7hEI3CXEi5kmn044I5yFayiMP2r4tVY8mU0dIG84qM9hjBJs9gpmS8eRz+SLEKgKHIkVbHwGv+JvHauy1UNwZGZmEuHr4DfUdALQzWU5kbMEYPLYrOyRcz4gHZTRY86g4qeHwUmiFORCsPhHAg/LKWcc9pl1LMmO8RJ2I/drO8peEcC7o6u8i+V4G5bQG2XE00Goz/HFdOwHOwcS+X+A==#/iK8ZpdSHi8OfVWwPaQORQ==#PRBWvd61bjiM09BH1btfO1z0CAEkIqusCIhufcwqyVXOCUaDZz9e36OxZZinlT3Ux6RH/PdNJHI0XuTi2gtxlBvREUXC8csmqVYy7XWf2OVPseeVi4XpskTeczfucXyVGaiycl50MTdViT1Eu903SU4yTwGifYROjUfpDFCQ8FUzSQzxEDAk/hDCR8wy4JME1DD7j5AABe/mhU75oe8pTG+Nj0CP7KWaxpw8xd0bt82jsczuPAizLeNsBsrU448goEPVYgiy1HexJQXZr35hcNnbtrfdrdXvPs1pkLHLoKlxdiEmf5SATzP/40ToQRQLX11kg51jg6noIkNhWuxiyASjhzo7K32axZ9PVXc1BzcL/4zit/oZ13diOdFEorwqzVFIXdS885QkU4Mg6VY8tJ9otwqPq2RWQoEX82VXiptQuKLB5SxToWGs++0KiI2eyT6BuvOGJGOKln2bEdtGHEyTD7woOYpqZOpCSjPPVuiQVd5H2JXy+X6G/dYKIrcEEkDrn3tr4oiLkE4AX8DfRg==
          something_else:  'right here'
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
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
  end

  it 'can handle decrypting multiline strings if the string is not encrypted' do
    tempfile = test.create_tempfile <<~HEREDOC
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
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
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
  end

  it 'when decrypting the settings, can handle names and values with regex special ' \
     'characters' do

    tempfile = test.create_tempfile <<~HEREDOC
      stuff:
        _secure_another+_setting: nE1uKJkVPHZIEiY9E4YpU+xtXZL+xtCxi8g7Q8tnPXdm786dFxA+YYGFszxN7UrwOdGG1UIIBH8MpO+rivdzPWZZhk849ZnRhhdMOUhy0T7jKqWUG7ygNfCpqWxRLUl1X87Hp8ZwVrhk9Q0bR+xX2U85xBT3SZAvTCGAcshpBvZuyDWB3dm5xfqiBooHenYlHeMRVndJBKu5m0V1v52gtnzr0QuaA49hOKCgy0/0n8B3iuXfDZNWoc8cb0f3fJmp7Izh2K/WNIOIuUkWV4vZ6yDTYNxADQLd597YGXgR8trbuHCyul6WDG9JAFdxjgVu4N9KGVLrLR3VfdIgNzy8BQ==
    HEREDOC

    settings_file = File.new  path:            tempfile.path,
                              decryption_keys: { __default: './spec/spec_key' }

    settings_file.decrypt

    expect(::File.read(tempfile.path)).to eql <<~HEREDOC
      stuff:
        _secure_another+_setting: Thanks for +all the fish
    HEREDOC
  end

  it 'can generate a signature file', :time_mock do
    seed           = SecureRandom.uuid
    file_path      = "/tmp/settings-#{seed}.yml"
    signature_path = "/tmp/settings-#{seed}.sig"

    ::File.write(file_path, <<~HEREDOC, mode: 'w+')
      stuff:
        another_setting: "Thanks for all the fish"
    HEREDOC

    settings_file = File.new  path:            file_path,
                              decryption_keys: { signature: './spec/spec_key' },
                              signature_name:  'Suzy Q Robinson'

    settings_file.sign

    expect(::File.read(signature_path)).to eql <<~HEREDOC
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

    ::File.write(file_path, <<~HEREDOC, mode: 'w+')
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

    ::File.write(file_path, <<~HEREDOC, mode: 'w+')
      stuff:
        another_setting: "Thanks for all the fish"
    HEREDOC

    ::File.write(signature_path, <<~HEREDOC, mode: 'w+')
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

    ::File.write(file_path, <<~HEREDOC, mode: 'w+')
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

  it 'can parse Regex values' do
    tempfile      = test.create_tempfile '{ test: !ruby/regexp /^(.*\\.|)example\\.com$/ }'
    settings_file = File.new(path: tempfile.path)

    file_settings = settings_file.to_settings

    expect(file_settings.to_hash).to eql('test' => /^(.*\.|)example\.com$/)
  end

  it 'can parse Date values' do
    tempfile      = test.create_tempfile '{ test: !ruby/date "2020-01-01" }'
    settings_file = File.new(path: tempfile.path)

    file_settings = settings_file.to_settings

    expect(file_settings.to_hash).to eql('test' => ::Date.new(2020, 1, 1))
  end

  it 'can parse Time values' do
    tempfile      = test.create_tempfile '{ test: !ruby/time "2020-01-01T00:00:00Z" }'
    settings_file = File.new(path: tempfile.path)

    file_settings = settings_file.to_settings

    expect(file_settings.to_hash).to eql('test' => ::Time.utc(2020, 1, 1, 0, 0, 0))
  end

  it 'warns when parsing unpermitted classes' do
    tempfile      = test.create_tempfile '{ test: !ruby/symbol foo }'
    settings_file = File.new(path: tempfile.path)

    expect { settings_file.to_settings }
      .to \
        raise_error(::Chamber::Errors::DisallowedClass)
          .with_message(include('Tried to load unspecified class: Symbol'))
  end
end
end
# rubocop:enable Layout/LineLength
