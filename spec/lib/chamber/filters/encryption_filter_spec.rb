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

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
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

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will attempt to encrypt values if they are numbers' do
    filtered_settings = EncryptionFilter.execute(secure_key_prefix: '_secure_',
                                                 data:              {
                                                   _secure_my_secure_setting: 12_345,
                                                 },
                                                 encryption_keys:   {
                                                   __default: './spec/spec_key.pub',
                                                 })

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt normal values if it guesses that they are already encrypted' do
    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7PzprewBX8C' \
                                   'XYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr054gGxeqZe' \
                                   'xbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntidMY9Lx4pqSkhY' \
                                   'XwQnI48d2Dh44qfaS9w2OrehSkpdFRnuxQeOpCKO/bleB0J88' \
                                   'WGkytCohyHCRIpbaEjEC3UD52pnqMeu/ClNm+PBgE6Ci94pu5' \
                                   'UUnZuIE/y+P4A3wgD6G/u8hgvAW51JwVryg/im1rayGAwWYNg' \
                                   'upQ/5LDmjffwx7Q3fyMH2uF3CDIKRIC6U+mnM5SRMO4Dzysw==',
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

  # rubocop:disable RSpec/ExampleLength
  it 'will not attempt to encrypt large values if it guesses that they are already encrypted' do
    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDBP2saOY63A' \
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
                                   'nEQcJgu0w/+dqSreqwp6TqaqXY3lzr8vi733lti4nss=',
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
  # rubocop:enable RSpec/ExampleLength

  it 'can encrypt long multiline strings' do
    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_multiline: <<-HEREDOC
-----BEGIN RSA PRIVATE KEY-----
uQ431irYF7XGEwmsfNUcw++6Enjmt9MItVZJrfL4cUr84L1ccOEX9AThsxz2nkiO
GgU+HtwwueZDUZ8Pdn71+1CdVaSUeEkVaYKYuHwYVb1spGfreHQHRP90EMv3U5Ir
xs0YFwKBgAJKGol+GM1oFodg48v4QA6hlF5z49v83wU+AS2f3aMVfjkTYgAEAoCT
qoSi7wkYK3NvftVgVi8Z2+1WEzp3S590UkkHmjc5o+HfS657v2fnqkekJyinB+OH
b5tySsPxt/3Un4D9EaGhjv44GMvL54vFI1Sqc8RsF/H8lRvj5ai5
-----END RSA PRIVATE KEY-----
        HEREDOC
      },
      encryption_keys:   { __default: './spec/spec_key.pub' },
    )

    my_secure_setting = filtered_settings._secure_multiline

    expect(my_secure_setting).to match(EncryptionFilter::LARGE_DATA_STRING_PATTERN)
  end

  it 'will encrypt strings of 127 chars effective length' do
    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'A' * 119,
      },
      encryption_keys:   { __default: './spec/spec_key.pub' },
    )

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN

    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'A' * 120,
      },
      encryption_keys:   { __default: './spec/spec_key.pub' },
    )

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end

  it 'will encrypt and decrypt strings larger than 128 chars' do
    filtered_settings = EncryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'long' * 100,
      },
      encryption_keys:   { __default: './spec/spec_key.pub' },
    )

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::LARGE_DATA_STRING_PATTERN
  end
end
end
end
