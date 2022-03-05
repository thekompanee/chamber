# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/decryption_filter'

module    Chamber
module    Filters
describe  DecryptionFilter do
  it 'will attempt multiple keys to decrypt values' do
    allow(EncryptionMethods::PublicKey).to receive(:decrypt).and_call_original

    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            development: {
              sub_key: {
                sub_sub_key: {
                  _secure_setting: 'RPaB5BEuo4Ht+97GA41GSD+fW4xABbJ/CvDZtnh/UqpCoiAG9' \
                                   'MlASlMsCrVEf6OH075Sm1X33Q3uJEoKEtdooqFF6rgUe9AV4r' \
                                   'p1nrclFCv9/bJJEemeV3tVMPMFqItxxIdGzMMYE9CuiL74TCQ' \
                                   'zcnvadOl1qWlQ4y/q+l5t8YEziB6IZSKYXQJw8SUHBtTitfH/' \
                                   'lnXqh27f2U6Y0WSlDC+LJHJLRo4x/0+Sc5CTRl78eGedctGjM' \
                                   'jRCrzg7MKvKzaKx2Quw7MnG9d/eOy05/uLTho/SosEjL6wTHh' \
                                   'MJMzWfeC5LPVuM4v9haSRZseZTkYeLczOpjn2W/PlOlvnWTw==',
                },
              },
            },
            other:       {
              sub_key: {
                sub_sub_key: {
                  _secure_setting: 'BZtWwj2KAuwxDCMoHvGRQmZwonh25vDxQUYXSNEUaxAx2ySVK' \
                                   'Jf5BsD166m1NUCpDTNr2u/s9u3TEQJCDaji6QU3zNshrs9JCe' \
                                   'yhs2ti7AR/ZoY2GYAOvATYIM4Hc8EsrlQjf+TWRwgLOwjd0QW' \
                                   'nyUWPVPrHcS+vk13rkkoOe03fVhb3gMuqQJn9Mlw08qW7oAFf' \
                                   'Qc3Fy/TgvmkSekMCtEbhNpa75xbk6RvDhTZKpHPXTq9/6jDXl' \
                                   'ukFo4MYX3zQ6AeGM8Rd+QsvwAWrlXhOTZ3qx8gLFuGWaD6Ggo' \
                                   'UDO5MoBZkSni4Ej1n/sBsbmF0jFY+EM6Z5Ajhn4VWoMerKfw==',
                },
              },
            },
          },
          decryption_keys:   {
            __default:   './spec/fixtures/keys/real/.chamber.pem',
            development: './spec/fixtures/keys/real/.chamber.development.pem',
          },
        )

    expect(filtered_settings.development.sub_key.sub_sub_key._secure_setting)
      .to eql 'hello development'

    expect(filtered_settings.other.sub_key.sub_sub_key._secure_setting)
      .to eql 'hello other'
  end

  it 'will attempt to decrypt values which are marked as "secure"' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTh' \
                                       'aV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4' \
                                       'akun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGy' \
                                       'dkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9' \
                                       'ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8' \
                                       'QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZ' \
                                       'gfXc86wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMn' \
                                       'z84XzmUp2Y0H1jPgGkBKQJKArfQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'will correct decrypt values which contain multiline strings' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'Q0ImhgdRmOdXEx04E3TnMoW/c6ckuce+y4kYGYWIJM6W/n'  \
                                       'BJBFjnqcFru/6wo+TVEZxowxjxJNv8H6SuxYmahxMRl7Aa'  \
                                       'jTrJ/QD+bKzbStL7D2oViB1dDNUz4GZxeNDSMU0oF9e67i' \
                                       'h6AmnxAgI0RlEterOMyWOPHJIUrLquBRlIs0JyP8yermN9' \
                                       'KWOAeLZdJlIGSyfwEU+sWQtafJ3jiNAPqWTGJxHfQZTQHn' \
                                       '+q4SnZPPnBPK0dZiZzqOrtkzmVPR7SAT5Ube4CxJWhkpWp' \
                                       'l5rPgamqVsG/P0AalMqLxuPUXqSdOEWKkK6jerbElVyQ7F' \
                                       'dRBLau2JXHpDZYGw8KTA==#EPCuIel5w17aUZfpHOuFNQ=' \
                                       '=#VzcE0BIuqA7xUMYEZkWZa4kOPse95Niow+e/FhKAlG/7' \
                                       'uYYTmkRbxRiMLtzH1Swzyz0NHF/BJPa1rKRbcVCGjK8v13' \
                                       'O9zJY8UdCQYsrdQaTIOA95NIcxwLCbrYencDzZFxYtOgio' \
                                       'yXbW9OCPnjDe9ozkCw6prRclgJyvadvKWqBgaJkluIdikC' \
                                       'DLX+Dy7fjkLtq5GqPFeFjHKwRGMLQB5dYk1VNAKgzhnSpU' \
                                       'kJJZA2Z7P54NhQQ83Doypfwb16LfKFax9575XeUWZeURxl' \
                                       '7Ric4MrjJYrc3u5biTzToMQBITGEsComsTDpfB3FVtZhob' \
                                       'NjzdkhEGzf6F2iRjjHDsQfaUebAPxDVFa31p5XGQN7YJDe' \
                                       'AXYBLb16kAhv8N5DGwiukPjtUVXUfFQzaTnJWm/eIhQKFH' \
                                       '8rkVawAr9wAeoSz7cwWFyD+pq5QF9GlxPU5ZotNjrqO4rz' \
                                       '/s8+bkt2XwBANTVCZrTb9gnE9FyIqFmRZ9L8Ef43KE02wD' \
                                       'cUnrKp3oOMSItWnY5rFJew0eAU+CHQ==',
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

  it 'will not attempt to decrypt values which are not marked as "secure"' do
    filtered_settings = \
      DecryptionFilter
        .execute(
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
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mpsspg/' \
                            'ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+QzCMJYnfY' \
                            '95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34ES' \
                            'z7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lr' \
                            'mQzk8QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc8' \
                            '6wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jP' \
                            'gGkBKQJKArfQ==',
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
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTh' \
                                       'aV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4a' \
                                       'kun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydk' \
                                       'EjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8' \
                                       'Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf' \
                                       '/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc8' \
                                       '6wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84Xzm' \
                                       'Up2Y0H1jPgGkBKQJKArfQ==',
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
    filtered_settings = \
      DecryptionFilter
        .execute(secure_key_prefix: '_secure_',
                 data:              {
                   _secure_my_secure_setting: 'hello',
                 },
                 decryption_keys:   {
                   __default: './spec/spec_key',
                 })

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'simply returns the encrypted string if there is no decryption key' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTh' \
                                       'aV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4a' \
                                       'kun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydk' \
                                       'EjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8' \
                                       'Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf' \
                                       '/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc8' \
                                       '6wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84Xzm' \
                                       'Up2Y0H1jPgGkBKQJKArfQ==',
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
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'rF1MIcLX/Q88gjpHTifI27fJHopDKVTJRvOwF2MZ8kVIrv' \
                                       'BhFgLOyQ7JEBiWNBh1yUtR6PeKlB+h44sIL3yKMcZyccX7' \
                                       '3Mo+CiWxmnjtK4I1QxcJL8OSLa8GQPlSBxoBCykWqerwN0' \
                                       'b2oS/jv8umB2j2RyANFYklD3mAxn1LsoTuFPAif+SCLRIG' \
                                       'afcHkOywM32qn6HhUpeBChX81JhJpip1gdJmRTGEZjKfR9' \
                                       '3h1shW0LqLLbdQUwYPOPbnjz7fU7x+d5/ighWTDsmOVyvE' \
                                       'iqM0WasFzK+WBUfvo8tQxUymexw/U3B7N/0R/9v6U3l6x7' \
                                       'eeIoQ4+lnJK2ULFzVgiw==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings._secure_my_secure_setting).to be_a Integer
    expect(filtered_settings._secure_my_secure_setting).to be   12_345
  end

  it 'can decrypt a number that has not been yamlled' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'Ieh5poOpcirj1jihkh1eENaCrF8ECQSLOigM4ApTZ8hp4v' \
                                       'rL3NKWp3djEkQz0QceopgN8TBJOEj1lqfGGL3Ar5L0SGrI' \
                                       'sHt6KOilerEXXH4/e2+s8JFWpdfjCxgn12fv1jqXxNyuMU' \
                                       'lYRBD7R+oRNVA5nNpnwiSE7IOBjUEZyzlQUrePVku5CtOs' \
                                       '0hfGe+79n6D8zFGTpx7UjZg4QVXyHISBM2hAaDOZ0dfxVq' \
                                       'bzmvN3B68xbuIty5vyv1+Ry2k+yIGJXIOjNm96ntDxIuUb' \
                                       'ycfrqYdtopBDI5kcr0zckPWMQRqkp7yd/XNZqyYCFGMNKN' \
                                       'wokE6wZuGffkD/H/VPxQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings._secure_my_secure_setting).to eql '12345'
  end

  it 'can decrypt a string that has not been yamlled' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'V2ifd6KwfGK8zW7K87ypHiA89UvVqsAX3961dR/B5ensru' \
                                       'VFi5KydFR1KxPQHxInhVl4GIvpBCwczK1mMZ61NGVISK04' \
                                       'tg90R52/ue0s4V9v01h1wTnahrkRGFyKk4iiQwsluuXGaW' \
                                       '4gBFayaKOs77HL/fMBY985akz8lv/8secg2U66YWeIHblJ' \
                                       '2OKdNELaEFZKXWywPxXEMPckAnbJB6liwFNjbY1y0WH6oi' \
                                       'P/OzoiOGzGeuUr2P8IfW8JIedOuy4JV4Y46QPvu4zCZhDg' \
                                       'Na4dTCdOTA/oEd5+GLhuoSiC87k/vbURwhqs1fmyXUJpUa' \
                                       'Dg3x4quTDZ6uBTG0Qu/A==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'can decrypt large encrypted data' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            _secure_my_secure_setting: 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDBP2saOY' \
                                       '63AD3C/SZanexlYDQoYoYC0V5J5EvKHgGMDAU8qnp9LjzU' \
                                       '5VCwJ3SVRGz3J0c7LXgTlC585Lgy8LX+/yjYFm4D13hlMv' \
                                       'vsoI35Bo8EVkTSU2+0gRSjRpQJeK1o7az5+fBuNmFipevA' \
                                       '4YfLnarnpwo2d2oO+BqStI2QQI1UWwN2R04rvOdHoEzA6D' \
                                       'LsdvYX+QTKDk4K5oSKXfuMBvzOCaCGT75cmt85ZY7XZnwb' \
                                       'Ki6c4mtL1ajrCr8sQFTA/GyG1EiYLFp1uQco0m2/S9yFf2' \
                                       '6REjax4ZE6O/ilXgT6xg==#YAm25swWRQx4ip1RjVzpGQ=' \
                                       '=#vRGvgjErI+dATM4UOtFkkgefFpFTvxGpHN0gRbf1VCO4' \
                                       'K07eqAQPb46BDI67a8iNum9cBphes7oGmuNnUvBg4JiZhK' \
                                       'sXnolcRWdITDVh/XYNioXRmesvj4x+tY0FVhkLV2zubRVf' \
                                       'C7CDJgin6wRHP+bcZhICDD2YqB+XRS4ou66UeaiGA4eV4G' \
                                       '6sPIo+DPjDM3m8JFnuRFMvGk73wthbN4MdAp9xONt5wfob' \
                                       'JUiUR11k2iAqwhx7Wyj0imz/afI8goDTdMfQt3VDOYqYG3' \
                                       'y2AcYOfsOL6m0GtQRlKvtsvw+m8/ICwSGiL2Loup0j/jDG' \
                                       'hFi1lwf4ded8aSwyS+2/Ks9C008dsJwpR1SxJ59z1KSzdQ' \
                                       'cTcrJTnxd+2qpOVVIoaRGud2tSV+5wKXy9dWRflLsjEtBR' \
                                       'FReFurTVQPodjDy+Lhs452/O/+KAJOXMKeYegCGOe8z9tL' \
                                       'D3teljjTyJPeW/1FE3+tP3G3HJAV4sgoO0YwhNY1Nji56i' \
                                       'gCl3UvEPnEQcJgu0w/+dqSreqwp6TqaqXY3lzr8vi733lt' \
                                       'i4nss=',
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
