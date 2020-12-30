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
            'development' => {
              'sub_key' => {
                'sub_sub_key' => {
                  '_secure_setting' => 'RPaB5BEuo4Ht+97GA41GSD+fW4xABbJ/CvDZtnh/U' \
                                       'qpCoiAG9MlASlMsCrVEf6OH075Sm1X33Q3uJEoKEt' \
                                       'dooqFF6rgUe9AV4rp1nrclFCv9/bJJEemeV3tVMPM' \
                                       'FqItxxIdGzMMYE9CuiL74TCQzcnvadOl1qWlQ4y/q' \
                                       '+l5t8YEziB6IZSKYXQJw8SUHBtTitfH/lnXqh27f2' \
                                       'U6Y0WSlDC+LJHJLRo4x/0+Sc5CTRl78eGedctGjMj' \
                                       'RCrzg7MKvKzaKx2Quw7MnG9d/eOy05/uLTho/SosE' \
                                       'jL6wTHhMJMzWfeC5LPVuM4v9haSRZseZTkYeLczOp' \
                                       'jn2W/PlOlvnWTw==',
                },
              },
            },
            'other'       => {
              'sub_key' => {
                'sub_sub_key' => {
                  '_secure_setting' => 'BZtWwj2KAuwxDCMoHvGRQmZwonh25vDxQUYXSNEUa' \
                                       'xAx2ySVKJf5BsD166m1NUCpDTNr2u/s9u3TEQJCDa' \
                                       'ji6QU3zNshrs9JCeyhs2ti7AR/ZoY2GYAOvATYIM4' \
                                       'Hc8EsrlQjf+TWRwgLOwjd0QWnyUWPVPrHcS+vk13r' \
                                       'kkoOe03fVhb3gMuqQJn9Mlw08qW7oAFfQc3Fy/Tgv' \
                                       'mkSekMCtEbhNpa75xbk6RvDhTZKpHPXTq9/6jDXlu' \
                                       'kFo4MYX3zQ6AeGM8Rd+QsvwAWrlXhOTZ3qx8gLFuG' \
                                       'WaD6GgoUDO5MoBZkSni4Ej1n/sBsbmF0jFY+EM6Z5' \
                                       'Ajhn4VWoMerKfw==',
                },
              },
            },
          },
          decryption_keys:   {
            __default:   './spec/fixtures/keys/real/.chamber.pem',
            development: './spec/fixtures/keys/real/.chamber.development.pem',
          },
        )

    expect(filtered_settings['development']['sub_key']['sub_sub_key']['_secure_setting'])
      .to eql 'hello development'

    expect(filtered_settings['other']['sub_key']['sub_sub_key']['_secure_setting'])
      .to eql 'hello other'
  end

  it 'will attempt to decrypt values which are marked as "secure"' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnM' \
                                           'oYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fxpt' \
                                           'THwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEAQLS' \
                                           'z4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34E' \
                                           'Sz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZDf' \
                                           '6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXWS' \
                                           '7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX' \
                                           '8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1' \
                                           'jPgGkBKQJKArfQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql 'hello'
  end

  it 'will correct decrypt values which contain multiline strings' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'Q0ImhgdRmOdXEx04E3TnMoW/c6ckuce+y4kYGYWIJ' \
                                           'M6W/nBJBFjnqcFru/6wo+TVEZxowxjxJNv8H6SuxY' \
                                           'mahxMRl7AajTrJ/QD+bKzbStL7D2oViB1dDNUz4GZ' \
                                           'xeNDSMU0oF9e67ih6AmnxAgI0RlEterOMyWOPHJIU' \
                                           'rLquBRlIs0JyP8yermN9KWOAeLZdJlIGSyfwEU+sW' \
                                           'QtafJ3jiNAPqWTGJxHfQZTQHn+q4SnZPPnBPK0dZi' \
                                           'ZzqOrtkzmVPR7SAT5Ube4CxJWhkpWpl5rPgamqVsG' \
                                           '/P0AalMqLxuPUXqSdOEWKkK6jerbElVyQ7FdRBLau' \
                                           '2JXHpDZYGw8KTA==#EPCuIel5w17aUZfpHOuFNQ==' \
                                           '#VzcE0BIuqA7xUMYEZkWZa4kOPse95Niow+e/FhKA' \
                                           'lG/7uYYTmkRbxRiMLtzH1Swzyz0NHF/BJPa1rKRbc' \
                                           'VCGjK8v13O9zJY8UdCQYsrdQaTIOA95NIcxwLCbrY' \
                                           'encDzZFxYtOgioyXbW9OCPnjDe9ozkCw6prRclgJy' \
                                           'vadvKWqBgaJkluIdikCDLX+Dy7fjkLtq5GqPFeFjH' \
                                           'KwRGMLQB5dYk1VNAKgzhnSpUkJJZA2Z7P54NhQQ83' \
                                           'Doypfwb16LfKFax9575XeUWZeURxl7Ric4MrjJYrc' \
                                           '3u5biTzToMQBITGEsComsTDpfB3FVtZhobNjzdkhE' \
                                           'Gzf6F2iRjjHDsQfaUebAPxDVFa31p5XGQN7YJDeAX' \
                                           'YBLb16kAhv8N5DGwiukPjtUVXUfFQzaTnJWm/eIhQ' \
                                           'KFH8rkVawAr9wAeoSz7cwWFyD+pq5QF9GlxPU5Zot' \
                                           'NjrqO4rz/s8+bkt2XwBANTVCZrTb9gnE9FyIqFmRZ' \
                                           '9L8Ef43KE02wDcUnrKp3oOMSItWnY5rFJew0eAU+C' \
                                           'HQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql <<-HEREDOC
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
            'my_secure_setting' => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                                   'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                                   '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                                   'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                                   'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                   'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                                   'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    my_secure_setting = filtered_settings['my_secure_setting']

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
            'secure_setting' => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mps' \
                                'spg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+Q' \
                                'zCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU3' \
                                '1YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZD' \
                                'f6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5' \
                                'eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kKTcdgbE9NcAhN' \
                                'r1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    secure_setting = filtered_settings['secure_setting']

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
            '_secure_my_secure_setting' => 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdn' \
                                           'MoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fxp' \
                                           'tTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEAQL' \
                                           'Sz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34' \
                                           'ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZD' \
                                           'f6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                           'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aao' \
                                           'X8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H' \
                                           '1jPgGkBKQJKArfQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    my_secure_setting = filtered_settings['_secure_my_secure_setting']

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
                   '_secure_my_secure_setting' => 'hello',
                 },
                 decryption_keys:   {
                   __default: './spec/spec_key',
                 })

    expect(filtered_settings['_secure_my_secure_setting']).to eql 'hello'
  end

  it 'simply returns the encrypted string if there is no decryption key' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdn' \
                                           'MoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fxp' \
                                           'tTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEAQL' \
                                           'Sz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34' \
                                           'ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZD' \
                                           'f6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                           'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aao' \
                                           'X8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H' \
                                           '1jPgGkBKQJKArfQ==',
          },
        )

    my_secure_setting = filtered_settings['_secure_my_secure_setting']

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
            '_secure_my_secure_setting' => 'rF1MIcLX/Q88gjpHTifI27fJHopDKVTJRvOwF2MZ8' \
                                           'kVIrvBhFgLOyQ7JEBiWNBh1yUtR6PeKlB+h44sIL3' \
                                           'yKMcZyccX73Mo+CiWxmnjtK4I1QxcJL8OSLa8GQPl' \
                                           'SBxoBCykWqerwN0b2oS/jv8umB2j2RyANFYklD3mA' \
                                           'xn1LsoTuFPAif+SCLRIGafcHkOywM32qn6HhUpeBC' \
                                           'hX81JhJpip1gdJmRTGEZjKfR93h1shW0LqLLbdQUw' \
                                           'YPOPbnjz7fU7x+d5/ighWTDsmOVyvEiqM0WasFzK+' \
                                           'WBUfvo8tQxUymexw/U3B7N/0R/9v6U3l6x7eeIoQ4' \
                                           '+lnJK2ULFzVgiw==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to be_a ::Integer
    expect(filtered_settings['_secure_my_secure_setting']).to be   12_345
  end

  it 'can decrypt a number that has not been yamlled' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'Ieh5poOpcirj1jihkh1eENaCrF8ECQSLOigM4ApTZ' \
                                           '8hp4vrL3NKWp3djEkQz0QceopgN8TBJOEj1lqfGGL' \
                                           '3Ar5L0SGrIsHt6KOilerEXXH4/e2+s8JFWpdfjCxg' \
                                           'n12fv1jqXxNyuMUlYRBD7R+oRNVA5nNpnwiSE7IOB' \
                                           'jUEZyzlQUrePVku5CtOs0hfGe+79n6D8zFGTpx7Uj' \
                                           'Zg4QVXyHISBM2hAaDOZ0dfxVqbzmvN3B68xbuIty5' \
                                           'vyv1+Ry2k+yIGJXIOjNm96ntDxIuUbycfrqYdtopB' \
                                           'DI5kcr0zckPWMQRqkp7yd/XNZqyYCFGMNKNwokE6w' \
                                           'ZuGffkD/H/VPxQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql '12345'
  end

  it 'can decrypt a string that has not been yamlled' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'V2ifd6KwfGK8zW7K87ypHiA89UvVqsAX3961dR/B5' \
                                           'ensruVFi5KydFR1KxPQHxInhVl4GIvpBCwczK1mMZ' \
                                           '61NGVISK04tg90R52/ue0s4V9v01h1wTnahrkRGFy' \
                                           'Kk4iiQwsluuXGaW4gBFayaKOs77HL/fMBY985akz8' \
                                           'lv/8secg2U66YWeIHblJ2OKdNELaEFZKXWywPxXEM' \
                                           'PckAnbJB6liwFNjbY1y0WH6oiP/OzoiOGzGeuUr2P' \
                                           '8IfW8JIedOuy4JV4Y46QPvu4zCZhDgNa4dTCdOTA/' \
                                           'oEd5+GLhuoSiC87k/vbURwhqs1fmyXUJpUaDg3x4q' \
                                           'uTDZ6uBTG0Qu/A==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql 'hello'
  end

  it 'can decrypt large encrypted data' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDBP' \
                                           '2saOY63AD3C/SZanexlYDQoYoYC0V5J5EvKHgGMDA' \
                                           'U8qnp9LjzU5VCwJ3SVRGz3J0c7LXgTlC585Lgy8LX' \
                                           '+/yjYFm4D13hlMvvsoI35Bo8EVkTSU2+0gRSjRpQJ' \
                                           'eK1o7az5+fBuNmFipevA4YfLnarnpwo2d2oO+BqSt' \
                                           'I2QQI1UWwN2R04rvOdHoEzA6DLsdvYX+QTKDk4K5o' \
                                           'SKXfuMBvzOCaCGT75cmt85ZY7XZnwbKi6c4mtL1aj' \
                                           'rCr8sQFTA/GyG1EiYLFp1uQco0m2/S9yFf26REjax' \
                                           '4ZE6O/ilXgT6xg==#YAm25swWRQx4ip1RjVzpGQ==' \
                                           '#vRGvgjErI+dATM4UOtFkkgefFpFTvxGpHN0gRbf1' \
                                           'VCO4K07eqAQPb46BDI67a8iNum9cBphes7oGmuNnU' \
                                           'vBg4JiZhKsXnolcRWdITDVh/XYNioXRmesvj4x+tY' \
                                           '0FVhkLV2zubRVfC7CDJgin6wRHP+bcZhICDD2YqB+' \
                                           'XRS4ou66UeaiGA4eV4G6sPIo+DPjDM3m8JFnuRFMv' \
                                           'Gk73wthbN4MdAp9xONt5wfobJUiUR11k2iAqwhx7W' \
                                           'yj0imz/afI8goDTdMfQt3VDOYqYG3y2AcYOfsOL6m' \
                                           '0GtQRlKvtsvw+m8/ICwSGiL2Loup0j/jDGhFi1lwf' \
                                           '4ded8aSwyS+2/Ks9C008dsJwpR1SxJ59z1KSzdQcT' \
                                           'crJTnxd+2qpOVVIoaRGud2tSV+5wKXy9dWRflLsjE' \
                                           'tBRFReFurTVQPodjDy+Lhs452/O/+KAJOXMKeYegC' \
                                           'GOe8z9tLD3teljjTyJPeW/1FE3+tP3G3HJAV4sgoO' \
                                           '0YwhNY1Nji56igCl3UvEPnEQcJgu0w/+dqSreqwp6' \
                                           'TqaqXY3lzr8vi733lti4nss=',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql 'long' * 100
  end

  it 'does not warn if decrypting nil' do
    allow(Chamber::EncryptionMethods::None).to receive(:warn)

    _filtered_settings = DecryptionFilter.execute(
                           secure_key_prefix: '_secure_',
                           data:              {
                             '_secure_my_secure_setting' => nil,
                           },
                           decryption_keys:   { __default: './spec/spec_key' },
                         )

    expect(Chamber::EncryptionMethods::None).not_to have_received(:warn)
  end
end
end
end
