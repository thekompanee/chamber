# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/encryption_filter'

module    Chamber
module    Filters
describe  EncryptionFilter do
  it 'will attempt to encrypt values which are marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: 'hello',
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will attempt to encrypt values with a key which matches the namespace of the ' \
     'value' do
    allow(EncryptionMethods::PublicKey).to receive(:encrypt).and_call_original

    default_key_filename     = './spec/fixtures/keys/real/.chamber.pub.pem'
    default_key_contents     = ::File.read(default_key_filename)
    default_key              = OpenSSL::PKey::RSA.new(default_key_contents)

    development_key_filename = './spec/fixtures/keys/real/.chamber.development.pub.pem'
    development_key_contents = ::File.read(development_key_filename)
    development_key          = OpenSSL::PKey::RSA.new(development_key_contents)

    production_key_filename  = './spec/fixtures/keys/real/.chamber.production.pub.pem'
    production_key_contents  = ::File.read(production_key_filename)
    production_key           = OpenSSL::PKey::RSA.new(production_key_contents)

    filtered_settings        = EncryptionFilter.execute(
                                 secure_key_prefix: '_secure_',
                                 data:              {
                                   development: {
                                     sub_key: {
                                       sub_sub_key: {
                                         _secure_setting: 'hello development',
                                       },
                                     },
                                   },
                                   production:  {
                                     sub_key: {
                                       sub_sub_key: {
                                         _secure_setting: 'hello production',
                                       },
                                     },
                                   },
                                   other:       {
                                     sub_key: {
                                       sub_sub_key: {
                                         _secure_setting: 'hello other',
                                       },
                                     },
                                   },
                                 },
                                 encryption_keys:   {
                                   __default:   default_key,
                                   development: development_key,
                                   production:  production_key,
                                 },
                               )

    expect(EncryptionMethods::PublicKey)
      .to have_received(:encrypt)
            .with(:_secure_setting, 'hello development', development_key)

    expect(EncryptionMethods::PublicKey)
      .to have_received(:encrypt)
            .with(:_secure_setting, 'hello other', default_key)

    expect(filtered_settings.development.sub_key.sub_sub_key._secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN

    expect(filtered_settings.production.sub_key.sub_sub_key._secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN

    expect(filtered_settings.other.sub_key.sub_sub_key._secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt values which are not marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            my_secure_setting: 'hello',
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings.my_secure_setting).to eql 'hello'
  end

  it 'will not attempt to encrypt values even if they are prefixed with "secure"' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            secure_setting: 'hello',
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings.secure_setting).to eql 'hello'
  end

  it 'will attempt to encrypt values if they are not properly encoded' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: 'fNI5\jwlBn',
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will attempt to encrypt values if they are numbers' do
    filtered_settings = EncryptionFilter.execute(secure_key_prefix: '_secure_',
                                                 data:              {
                                                   _secure_my_secure_setting: 12_345,
                                                 },
                                                 encryption_keys:   {
                                                   __default: './spec/spec_key.pub',
                                                 })

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt normal values if it guesses that they are already encrypted' do
    filtered_settings = \
      EncryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7PzprewB' \
                                       'X8CXYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr054g' \
                                       'GxeqZexbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntidMY9' \
                                       'Lx4pqSkhYXwQnI48d2Dh44qfaS9w2OrehSkpdFRnuxQeOp' \
                                       'CKO/bleB0J88WGkytCohyHCRIpbaEjEC3UD52pnqMeu/Cl' \
                                       'Nm+PBgE6Ci94pu5UUnZuIE/y+P4A3wgD6G/u8hgvAW51Jw' \
                                       'Vryg/im1rayGAwWYNgupQ/5LDmjffwx7Q3fyMH2uF3CDIK' \
                                       'RIC6U+mnM5SRMO4Dzysw==',
          },
          encryption_keys:   { __default: './spec/spec_key.pub' },
        )

    my_secure_setting = filtered_settings._secure_my_secure_setting

    expect(my_secure_setting).to eql 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7Pzprew' \
                                     'BX8CXYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr05' \
                                     '4gGxeqZexbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntid' \
                                     'MY9Lx4pqSkhYXwQnI48d2Dh44qfaS9w2OrehSkpdFRnux' \
                                     'QeOpCKO/bleB0J88WGkytCohyHCRIpbaEjEC3UD52pnqM' \
                                     'eu/ClNm+PBgE6Ci94pu5UUnZuIE/y+P4A3wgD6G/u8hgv' \
                                     'AW51JwVryg/im1rayGAwWYNgupQ/5LDmjffwx7Q3fyMH2' \
                                     'uF3CDIKRIC6U+mnM5SRMO4Dzysw=='
  end

  it 'will not attempt to encrypt large values if it guesses that they are already encrypted' do
    filtered_settings = \
      EncryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDBP2saOY6' \
                                       '3AD3C/SZanexlYDQoYoYC0V5J5EvKHgGMDAU8qnp9LjzU5V' \
                                       'CwJ3SVRGz3J0c7LXgTlC585Lgy8LX+/yjYFm4D13hlMvvso' \
                                       'I35Bo8EVkTSU2+0gRSjRpQJeK1o7az5+fBuNmFipevA4YfL' \
                                       'narnpwo2d2oO+BqStI2QQI1UWwN2R04rvOdHoEzA6DLsdvY' \
                                       'X+QTKDk4K5oSKXfuMBvzOCaCGT75cmt85ZY7XZnwbKi6c4m' \
                                       'tL1ajrCr8sQFTA/GyG1EiYLFp1uQco0m2/S9yFf26REjax4' \
                                       'ZE6O/ilXgT6xg==#YAm25swWRQx4ip1RjVzpGQ==#vRGvgj' \
                                       'ErI+dATM4UOtFkkgefFpFTvxGpHN0gRbf1VCO4K07eqAQPb' \
                                       '46BDI67a8iNum9cBphes7oGmuNnUvBg4JiZhKsXnolcRWdI' \
                                       'TDVh/XYNioXRmesvj4x+tY0FVhkLV2zubRVfC7CDJgin6wR' \
                                       'HP+bcZhICDD2YqB+XRS4ou66UeaiGA4eV4G6sPIo+DPjDM3' \
                                       'm8JFnuRFMvGk73wthbN4MdAp9xONt5wfobJUiUR11k2iAqw' \
                                       'hx7Wyj0imz/afI8goDTdMfQt3VDOYqYG3y2AcYOfsOL6m0G' \
                                       'tQRlKvtsvw+m8/ICwSGiL2Loup0j/jDGhFi1lwf4ded8aSw' \
                                       'yS+2/Ks9C008dsJwpR1SxJ59z1KSzdQcTcrJTnxd+2qpOVV' \
                                       'IoaRGud2tSV+5wKXy9dWRflLsjEtBRFReFurTVQPodjDy+L' \
                                       'hs452/O/+KAJOXMKeYegCGOe8z9tLD3teljjTyJPeW/1FE3' \
                                       '+tP3G3HJAV4sgoO0YwhNY1Nji56igCl3UvEPnEQcJgu0w/+' \
                                       'dqSreqwp6TqaqXY3lzr8vi733lti4nss=',
          },
          encryption_keys:   { __default: './spec/spec_key.pub' },
        )

    my_secure_setting = filtered_settings._secure_my_secure_setting

    expect(my_secure_setting).to eql 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDBP2saOY63A' \
                                     'D3C/SZanexlYDQoYoYC0V5J5EvKHgGMDAU8qnp9LjzU5VCwJ3' \
                                     'SVRGz3J0c7LXgTlC585Lgy8LX+/yjYFm4D13hlMvvsoI35Bo8' \
                                     'EVkTSU2+0gRSjRpQJeK1o7az5+fBuNmFipevA4YfLnarnpwo2' \
                                     'd2oO+BqStI2QQI1UWwN2R04rvOdHoEzA6DLsdvYX+QTKDk4K5' \
                                     'oSKXfuMBvzOCaCGT75cmt85ZY7XZnwbKi6c4mtL1ajrCr8sQF' \
                                     'TA/GyG1EiYLFp1uQco0m2/S9yFf26REjax4ZE6O/ilXgT6xg=' \
                                     '=#YAm25swWRQx4ip1RjVzpGQ==#vRGvgjErI+dATM4UOtFkkg' \
                                     'efFpFTvxGpHN0gRbf1VCO4K07eqAQPb46BDI67a8iNum9cBph' \
                                     'es7oGmuNnUvBg4JiZhKsXnolcRWdITDVh/XYNioXRmesvj4x+' \
                                     'tY0FVhkLV2zubRVfC7CDJgin6wRHP+bcZhICDD2YqB+XRS4ou' \
                                     '66UeaiGA4eV4G6sPIo+DPjDM3m8JFnuRFMvGk73wthbN4MdAp' \
                                     '9xONt5wfobJUiUR11k2iAqwhx7Wyj0imz/afI8goDTdMfQt3V' \
                                     'DOYqYG3y2AcYOfsOL6m0GtQRlKvtsvw+m8/ICwSGiL2Loup0j' \
                                     '/jDGhFi1lwf4ded8aSwyS+2/Ks9C008dsJwpR1SxJ59z1KSzd' \
                                     'QcTcrJTnxd+2qpOVVIoaRGud2tSV+5wKXy9dWRflLsjEtBRFR' \
                                     'eFurTVQPodjDy+Lhs452/O/+KAJOXMKeYegCGOe8z9tLD3tel' \
                                     'jjTyJPeW/1FE3+tP3G3HJAV4sgoO0YwhNY1Nji56igCl3UvEP' \
                                     'nEQcJgu0w/+dqSreqwp6TqaqXY3lzr8vi733lti4nss='
  end

  it 'can encrypt long multiline strings' do
    filtered_settings = \
      EncryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_multiline: "-----BEGIN RSA PRIVATE KEY-----" \
                               "uQ431irYF7XGEwmsfNUcw++6Enjmt9MIt" \
                               "VZJrfL4cUr84L1ccOEX9AThsxz2nkiO\n" \
                               "GgU+HtwwueZDUZ8Pdn71+1CdVaSUeEkVa" \
                               "YKYuHwYVb1spGfreHQHRP90EMv3U5Ir\n" \
                               "xs0YFwKBgAJKGol+GM1oFodg48v4QA6hl" \
                               "F5z49v83wU+AS2f3aMVfjkTYgAEAoCT\n" \
                               "qoSi7wkYK3NvftVgVi8Z2+1WEzp3S590U" \
                               "kkHmjc5o+HfS657v2fnqkekJyinB+OH\n" \
                               "b5tySsPxt/3Un4D9EaGhjv44GMvL54vFI" \
                               "1Sqc8RsF/H8lRvj5ai5\n" \
                               "-----END RSA PRIVATE KEY-----",
          },
          encryption_keys:   {
            __default: './spec/spec_key.pub',
          },
        )

    my_secure_setting = filtered_settings._secure_multiline

    expect(my_secure_setting).to match(EncryptionFilter::LARGE_DATA_STRING_PATTERN)
  end

  it 'will encrypt strings of 127 chars effective length' do
    filtered_settings = \
      EncryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'A' * 119,
          },
          encryption_keys:   { __default: './spec/spec_key.pub' },
        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN

    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: 'A' * 124,
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end

  it 'will encrypt and decrypt strings larger than 128 chars' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: 'long' * 100,
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end

  it 'will encrypt values which are Regexes via public key' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: /^(.*\\.|)example\\.com$/,
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will encrypt values which are Regexes via SSL' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: %r{^(.*\\.|)example\\.com/abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz},
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end

  it 'will encrypt values which are Dates' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: ::Date.new(2020, 1, 1),
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will encrypt values which are Times' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: ::Time.utc(2020, 1, 1, 0, 0, 0),
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will encrypt values which are unsupported via Public Key' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: :foo_symbol,
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will encrypt values which are unsupported via SSL' do
    filtered_settings = EncryptionFilter.execute(
                          secure_key_prefix: '_secure_',
                          data:              {
                            _secure_my_secure_setting: :abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz,
                          },
                          encryption_keys:   { __default: './spec/spec_key.pub' },
                        )

    expect(filtered_settings._secure_my_secure_setting)
      .to match EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end
end
end
end
