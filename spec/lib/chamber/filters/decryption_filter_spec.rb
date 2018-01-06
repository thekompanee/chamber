# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/decryption_filter'

module    Chamber
module    Filters
describe  DecryptionFilter do
  it 'will attempt to decrypt values which are marked as "secure"' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                                   'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                                   '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                                   'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                                   'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                   'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                                   'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  # rubocop:disable RSpec/ExampleLength
  it 'will correct decrypt values which contain multiline strings' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'Q0ImhgdRmOdXEx04E3TnMoW/c6ckuce+y4kYGYWIJM6W/nBJBF' \
                                   'jnqcFru/6wo+TVEZxowxjxJNv8H6SuxYmahxMRl7AajTrJ/QD+' \
                                   'bKzbStL7D2oViB1dDNUz4GZxeNDSMU0oF9e67ih6AmnxAgI0Rl' \
                                   'EterOMyWOPHJIUrLquBRlIs0JyP8yermN9KWOAeLZdJlIGSyfw' \
                                   'EU+sWQtafJ3jiNAPqWTGJxHfQZTQHn+q4SnZPPnBPK0dZiZzqO' \
                                   'rtkzmVPR7SAT5Ube4CxJWhkpWpl5rPgamqVsG/P0AalMqLxuPU' \
                                   'XqSdOEWKkK6jerbElVyQ7FdRBLau2JXHpDZYGw8KTA==#EPCuI' \
                                   'el5w17aUZfpHOuFNQ==#VzcE0BIuqA7xUMYEZkWZa4kOPse95N' \
                                   'iow+e/FhKAlG/7uYYTmkRbxRiMLtzH1Swzyz0NHF/BJPa1rKRb' \
                                   'cVCGjK8v13O9zJY8UdCQYsrdQaTIOA95NIcxwLCbrYencDzZFx' \
                                   'YtOgioyXbW9OCPnjDe9ozkCw6prRclgJyvadvKWqBgaJkluIdi' \
                                   'kCDLX+Dy7fjkLtq5GqPFeFjHKwRGMLQB5dYk1VNAKgzhnSpUkJ' \
                                   'JZA2Z7P54NhQQ83Doypfwb16LfKFax9575XeUWZeURxl7Ric4M' \
                                   'rjJYrc3u5biTzToMQBITGEsComsTDpfB3FVtZhobNjzdkhEGzf' \
                                   '6F2iRjjHDsQfaUebAPxDVFa31p5XGQN7YJDeAXYBLb16kAhv8N' \
                                   '5DGwiukPjtUVXUfFQzaTnJWm/eIhQKFH8rkVawAr9wAeoSz7cw' \
                                   'WFyD+pq5QF9GlxPU5ZotNjrqO4rz/s8+bkt2XwBANTVCZrTb9g' \
                                   'nE9FyIqFmRZ9L8Ef43KE02wDcUnrKp3oOMSItWnY5rFJew0eAU' \
                                   '+CHQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to eql <<-HEREDOC
-----BEGIN RSA PRIVATE KEY-----
uQ431irYF7XGEwmsfNUcw++6Enjmt9MItVZJrfL4cUr84L1ccOEX9AThsxz2nkiO
GgU+HtwwueZDUZ8Pdn71+1CdVaSUeEkVaYKYuHwYVb1spGfreHQHRP90EMv3U5Ir
xs0YFwKBgAJKGol+GM1oFodg48v4QA6hlF5z49v83wU+AS2f3aMVfjkTYgAEAoCT
qoSi7wkYK3NvftVgVi8Z2+1WEzp3S590UkkHmjc5o+HfS657v2fnqkekJyinB+OH
b5tySsPxt/3Un4D9EaGhjv44GMvL54vFI1Sqc8RsF/H8lRvj5ai5
-----END RSA PRIVATE KEY-----
    HEREDOC
  end
  # rubocop:enable RSpec/ExampleLength

  it 'will not attempt to decrypt values which are not marked as "secure"' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                           'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                           '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                           'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                           'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                           'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                           'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    my_secure_setting = filtered_settings.my_secure_setting

    expect(my_secure_setting).to eql 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYT' \
                                     'haV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJU' \
                                     'd4akun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4L' \
                                     'DGydkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9Dj' \
                                     'kBb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lr' \
                                     'mQzk8QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBf' \
                                     'v5ZFrZgfXc86wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1' \
                                     '+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ=='
  end

  it 'will not attempt to decrypt values even if they are prefixed with "secure"' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mpsspg/ZTBt' \
                        'mjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/em' \
                        'EAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9Djk' \
                        'Bb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxs' \
                        'WVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kKT' \
                        'cdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    secure_setting = filtered_settings.secure_setting

    expect(secure_setting).to eql 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                                  'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                                  '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                                  'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                                  'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                  'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                                  'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ=='
  end

  it 'will not attempt to decrypt values even if they are not properly encoded' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4' \
                                   'mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ' \
                                   '57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfX' \
                                   'znf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZ' \
                                   'DwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNX' \
                                   'WS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1k' \
                                   'KTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    my_secure_setting = filtered_settings._secure_my_secure_setting

    expect(my_secure_setting).to eql 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4' \
                                     'mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ' \
                                     '57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfX' \
                                     'znf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZ' \
                                     'DwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNX' \
                                     'WS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1k' \
                                     'KTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ=='
  end

  it 'will not attempt to decrypt values if it guesses that they are not encrpyted' do
    filtered_settings = DecryptionFilter.execute(secure_key_prefix: '_secure_',
                                                 data:              {
                                                   _secure_my_secure_setting: 'hello',
                                                 },
                                                 decryption_keys:   {
                                                   __default: './spec/spec_key',
                                                 })

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'simply returns the encrypted string if there is no decryption key' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4' \
                                   'mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ' \
                                   '57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfX' \
                                   'znf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZ' \
                                   'DwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNX' \
                                   'WS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1k' \
                                   'KTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
    )

    my_secure_setting = filtered_settings._secure_my_secure_setting

    expect(my_secure_setting).to eql 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4' \
                                     'mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ' \
                                     '57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfX' \
                                     'znf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZ' \
                                     'DwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNX' \
                                     'WS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1k' \
                                     'KTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ=='
  end

  it 'can decrypt a complex object' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'rF1MIcLX/Q88gjpHTifI27fJHopDKVTJRvOwF2MZ8kVIrvBhFg' \
                                   'LOyQ7JEBiWNBh1yUtR6PeKlB+h44sIL3yKMcZyccX73Mo+CiWx' \
                                   'mnjtK4I1QxcJL8OSLa8GQPlSBxoBCykWqerwN0b2oS/jv8umB2' \
                                   'j2RyANFYklD3mAxn1LsoTuFPAif+SCLRIGafcHkOywM32qn6Hh' \
                                   'UpeBChX81JhJpip1gdJmRTGEZjKfR93h1shW0LqLLbdQUwYPOP' \
                                   'bnjz7fU7x+d5/ighWTDsmOVyvEiqM0WasFzK+WBUfvo8tQxUym' \
                                   'exw/U3B7N/0R/9v6U3l6x7eeIoQ4+lnJK2ULFzVgiw==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to be_a Integer
    expect(filtered_settings._secure_my_secure_setting).to be   12_345
  end

  it 'can decrypt a number that has not been yamlled' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'Ieh5poOpcirj1jihkh1eENaCrF8ECQSLOigM4ApTZ8hp4vrL3N' \
                                   'KWp3djEkQz0QceopgN8TBJOEj1lqfGGL3Ar5L0SGrIsHt6KOil' \
                                   'erEXXH4/e2+s8JFWpdfjCxgn12fv1jqXxNyuMUlYRBD7R+oRNV' \
                                   'A5nNpnwiSE7IOBjUEZyzlQUrePVku5CtOs0hfGe+79n6D8zFGT' \
                                   'px7UjZg4QVXyHISBM2hAaDOZ0dfxVqbzmvN3B68xbuIty5vyv1' \
                                   '+Ry2k+yIGJXIOjNm96ntDxIuUbycfrqYdtopBDI5kcr0zckPWM' \
                                   'QRqkp7yd/XNZqyYCFGMNKNwokE6wZuGffkD/H/VPxQ==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to eql '12345'
  end

  it 'can decrypt a string that has not been yamlled' do
    filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: 'V2ifd6KwfGK8zW7K87ypHiA89UvVqsAX3961dR/B5ensruVFi5' \
                                   'KydFR1KxPQHxInhVl4GIvpBCwczK1mMZ61NGVISK04tg90R52/' \
                                   'ue0s4V9v01h1wTnahrkRGFyKk4iiQwsluuXGaW4gBFayaKOs77' \
                                   'HL/fMBY985akz8lv/8secg2U66YWeIHblJ2OKdNELaEFZKXWyw' \
                                   'PxXEMPckAnbJB6liwFNjbY1y0WH6oiP/OzoiOGzGeuUr2P8IfW' \
                                   '8JIedOuy4JV4Y46QPvu4zCZhDgNa4dTCdOTA/oEd5+GLhuoSiC' \
                                   '87k/vbURwhqs1fmyXUJpUaDg3x4quTDZ6uBTG0Qu/A==',
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'can decrypt large encrypted data' do
    filtered_settings = DecryptionFilter.execute(
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
        decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(filtered_settings._secure_my_secure_setting).to eql 'long' * 100
  end

  it 'does not warn if decrypting nil' do
    allow(Chamber::EncryptionMethods::None).to receive(:warn)

    _filtered_settings = DecryptionFilter.execute(
      secure_key_prefix: '_secure_',
      data:              {
        _secure_my_secure_setting: nil,
      },
      decryption_keys:   { __default: './spec/spec_key' },
    )

    expect(Chamber::EncryptionMethods::None).not_to have_received(:warn)
  end
end
end
end
