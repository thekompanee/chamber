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
                  '_secure_setting' => 'RPaB5BEuo4Ht+97GA41GSD+fW4xABbJ/CvDZtnh/' \
                                       'UqpCoiAG9MlASlMsCrVEf6OH075Sm1X33Q3uJEoK' \
                                       'EtdooqFF6rgUe9AV4rp1nrclFCv9/bJJEemeV3tV' \
                                       'MPMFqItxxIdGzMMYE9CuiL74TCQzcnvadOl1qWlQ' \
                                       '4y/q+l5t8YEziB6IZSKYXQJw8SUHBtTitfH/lnXq' \
                                       'h27f2U6Y0WSlDC+LJHJLRo4x/0+Sc5CTRl78eGed' \
                                       'ctGjMjRCrzg7MKvKzaKx2Quw7MnG9d/eOy05/uLT' \
                                       'ho/SosEjL6wTHhMJMzWfeC5LPVuM4v9haSRZseZT' \
                                       'kYeLczOpjn2W/PlOlvnWTw==',
                },
              },
            },
            'other'       => {
              'sub_key' => {
                'sub_sub_key' => {
                  '_secure_setting' => 'BZtWwj2KAuwxDCMoHvGRQmZwonh25vDxQUYXSNEU' \
                                       'axAx2ySVKJf5BsD166m1NUCpDTNr2u/s9u3TEQJC' \
                                       'Daji6QU3zNshrs9JCeyhs2ti7AR/ZoY2GYAOvATY' \
                                       'IM4Hc8EsrlQjf+TWRwgLOwjd0QWnyUWPVPrHcS+v' \
                                       'k13rkkoOe03fVhb3gMuqQJn9Mlw08qW7oAFfQc3F' \
                                       'y/TgvmkSekMCtEbhNpa75xbk6RvDhTZKpHPXTq9/' \
                                       '6jDXlukFo4MYX3zQ6AeGM8Rd+QsvwAWrlXhOTZ3q' \
                                       'x8gLFuGWaD6GgoUDO5MoBZkSni4Ej1n/sBsbmF0j' \
                                       'FY+EM6Z5Ajhn4VWoMerKfw==',
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
            '_secure_my_secure_setting' => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdn' \
                                           'MoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fx' \
                                           'ptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEA' \
                                           'QLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUT' \
                                           'f34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5k' \
                                           'LAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlz' \
                                           'pKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgU' \
                                           'Kc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84Xz' \
                                           'mUp2Y0H1jPgGkBKQJKArfQ==',
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
            '_secure_my_secure_setting' => 'Q0ImhgdRmOdXEx04E3TnMoW/c6ckuce+y4kYGYWI' \
                                           'JM6W/nBJBFjnqcFru/6wo+TVEZxowxjxJNv8H6Su' \
                                           'xYmahxMRl7AajTrJ/QD+bKzbStL7D2oViB1dDNUz' \
                                           '4GZxeNDSMU0oF9e67ih6AmnxAgI0RlEterOMyWOP' \
                                           'HJIUrLquBRlIs0JyP8yermN9KWOAeLZdJlIGSyfw' \
                                           'EU+sWQtafJ3jiNAPqWTGJxHfQZTQHn+q4SnZPPnB' \
                                           'PK0dZiZzqOrtkzmVPR7SAT5Ube4CxJWhkpWpl5rP' \
                                           'gamqVsG/P0AalMqLxuPUXqSdOEWKkK6jerbElVyQ' \
                                           '7FdRBLau2JXHpDZYGw8KTA==#EPCuIel5w17aUZf' \
                                           'pHOuFNQ==#VzcE0BIuqA7xUMYEZkWZa4kOPse95N' \
                                           'iow+e/FhKAlG/7uYYTmkRbxRiMLtzH1Swzyz0NHF' \
                                           '/BJPa1rKRbcVCGjK8v13O9zJY8UdCQYsrdQaTIOA' \
                                           '95NIcxwLCbrYencDzZFxYtOgioyXbW9OCPnjDe9o' \
                                           'zkCw6prRclgJyvadvKWqBgaJkluIdikCDLX+Dy7f' \
                                           'jkLtq5GqPFeFjHKwRGMLQB5dYk1VNAKgzhnSpUkJ' \
                                           'JZA2Z7P54NhQQ83Doypfwb16LfKFax9575XeUWZe' \
                                           'URxl7Ric4MrjJYrc3u5biTzToMQBITGEsComsTDp' \
                                           'fB3FVtZhobNjzdkhEGzf6F2iRjjHDsQfaUebAPxD' \
                                           'VFa31p5XGQN7YJDeAXYBLb16kAhv8N5DGwiukPjt' \
                                           'UVXUfFQzaTnJWm/eIhQKFH8rkVawAr9wAeoSz7cw' \
                                           'WFyD+pq5QF9GlxPU5ZotNjrqO4rz/s8+bkt2XwBA' \
                                           'NTVCZrTb9gnE9FyIqFmRZ9L8Ef43KE02wDcUnrKp' \
                                           '3oOMSItWnY5rFJew0eAU+CHQ==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql <<~HEREDOC
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
            'secure_setting' => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdn' \
                                'MoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fx' \
                                'ptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEA' \
                                'QLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUT' \
                                'f34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5k' \
                                'LAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlz' \
                                'pKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgU' \
                                'Kc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84Xz' \
                                'mUp2Y0H1jPgGkBKQJKArfQ==',
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
            '_secure_my_secure_setting' => 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUd' \
                                           'nMoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3F' \
                                           'xptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emE' \
                                           'AQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJU' \
                                           'Tf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5' \
                                           'kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVl' \
                                           'zpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdg' \
                                           'UKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84X' \
                                           'zmUp2Y0H1jPgGkBKQJKArfQ==',
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
            '_secure_my_secure_setting' => 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUd' \
                                           'nMoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3F' \
                                           'xptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emE' \
                                           'AQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJU' \
                                           'Tf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5' \
                                           'kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVl' \
                                           'zpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdg' \
                                           'UKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84X' \
                                           'zmUp2Y0H1jPgGkBKQJKArfQ==',
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
            '_secure_my_secure_setting' => 'rF1MIcLX/Q88gjpHTifI27fJHopDKVTJRvOwF2MZ' \
                                           '8kVIrvBhFgLOyQ7JEBiWNBh1yUtR6PeKlB+h44sI' \
                                           'L3yKMcZyccX73Mo+CiWxmnjtK4I1QxcJL8OSLa8G' \
                                           'QPlSBxoBCykWqerwN0b2oS/jv8umB2j2RyANFYkl' \
                                           'D3mAxn1LsoTuFPAif+SCLRIGafcHkOywM32qn6Hh' \
                                           'UpeBChX81JhJpip1gdJmRTGEZjKfR93h1shW0LqL' \
                                           'LbdQUwYPOPbnjz7fU7x+d5/ighWTDsmOVyvEiqM0' \
                                           'WasFzK+WBUfvo8tQxUymexw/U3B7N/0R/9v6U3l6' \
                                           'x7eeIoQ4+lnJK2ULFzVgiw==',
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
            '_secure_my_secure_setting' => 'Ieh5poOpcirj1jihkh1eENaCrF8ECQSLOigM4ApT' \
                                           'Z8hp4vrL3NKWp3djEkQz0QceopgN8TBJOEj1lqfG' \
                                           'GL3Ar5L0SGrIsHt6KOilerEXXH4/e2+s8JFWpdfj' \
                                           'Cxgn12fv1jqXxNyuMUlYRBD7R+oRNVA5nNpnwiSE' \
                                           '7IOBjUEZyzlQUrePVku5CtOs0hfGe+79n6D8zFGT' \
                                           'px7UjZg4QVXyHISBM2hAaDOZ0dfxVqbzmvN3B68x' \
                                           'buIty5vyv1+Ry2k+yIGJXIOjNm96ntDxIuUbycfr' \
                                           'qYdtopBDI5kcr0zckPWMQRqkp7yd/XNZqyYCFGMN' \
                                           'KNwokE6wZuGffkD/H/VPxQ==',
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
            '_secure_my_secure_setting' => 'V2ifd6KwfGK8zW7K87ypHiA89UvVqsAX3961dR/B' \
                                           '5ensruVFi5KydFR1KxPQHxInhVl4GIvpBCwczK1m' \
                                           'MZ61NGVISK04tg90R52/ue0s4V9v01h1wTnahrkR' \
                                           'GFyKk4iiQwsluuXGaW4gBFayaKOs77HL/fMBY985' \
                                           'akz8lv/8secg2U66YWeIHblJ2OKdNELaEFZKXWyw' \
                                           'PxXEMPckAnbJB6liwFNjbY1y0WH6oiP/OzoiOGzG' \
                                           'euUr2P8IfW8JIedOuy4JV4Y46QPvu4zCZhDgNa4d' \
                                           'TCdOTA/oEd5+GLhuoSiC87k/vbURwhqs1fmyXUJp' \
                                           'UaDg3x4quTDZ6uBTG0Qu/A==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to eql 'hello'
  end

  it 'can decrypt a Regex/Complex Object via Public Key' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'k0zVCImR6l5T+8mPDmARL4xYJCYjhNZ2eVOOIXIa' \
                                           'CK66ECFHyTsn1fcf8VW6lu2+veQC1DanvK4qHIC3' \
                                           'suYeZorGoy7ImskfqSXlPotOG1NGhi98NUkVOZ0R' \
                                           'HRU27e74OUpQR0lrL6js/+L3F34B24j1Q0385+N8' \
                                           '6jREz8GFwtcq38oQcqu3oq/L8+NyC8zhSiw2YYlm' \
                                           'dsh0itAgvX18Odfp4DiRl7IBywUlnRrIWbnWSn2B' \
                                           'NW5dnyuxQxdJabG/f7uN5WoN6yJsg6R3cK4UXAGk' \
                                           'NLiRIf1gwwi8X/7CxoTgBufgb+E/r/D1a2Qt4jH6' \
                                           'vnF9pjujmLPvfeNO2hCfNw==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to be_a(::Regexp)
    expect(filtered_settings['_secure_my_secure_setting'])
      .to eql(/^(.*\\.|)example\\.com$/)
  end

  it 'can decrypt a Regex/Complex Object via SSL' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'au4zXBf6WW6Aexk48KlcP7OIw+B8VEmo2x67+CFn' \
                                           'GOIOVvOx/iU7bh8DDQCtkGQwZjJ1GUM+yj49H7nS' \
                                           'PAq39k/KhKGjZ526DaPuWR8PxJbx/j9FeifFknBu' \
                                           'WCDLrhlYnI2LmREUnJanPfhzB3DAmjslVhvZkZKR' \
                                           'DgNLhMGUTqHHLb91cAV5+zZi+Pl1Pk9BOlZNaW+C' \
                                           'NAnYoSHdcSjFW0GDbguiwJGqrj96PegB0rd1AbyN' \
                                           'Js3s8MN7cmSLe7bmKnis80HXPy6s9940z5OLt3Hb' \
                                           'dBAvHCZi4P+J4v3skf9voZjrQh/+QXrEQ53uzFJE' \
                                           'E4bnUYw3GQoA8PqFxLNIVA==#XIgXdLlQjVzdU/8' \
                                           'qSgLS0w==#9sYdofYOZZIBGfNrGsI6ZmD1+1VxzQ' \
                                           'CHYL/Uyh1ulYnH/MUX9Oe21QnVcIGjYC+eZDxbiC' \
                                           '+xFF91vl6+pwowuhVV90OGtMZIPPb3/JmkOrvSFS' \
                                           '5OMDZQP3EJ3HUbo4upeYdIx12/5WPoxrYSOAxRFG' \
                                           'ylRfV2nlWG/mBNci9Wx61zVWvEmxKBYsSqSpiCER' \
                                           'uqKh742OIgUK6oN6Lq0veVOXBEyNLbt/EGXJ1x4U' \
                                           'd4tL8=',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to      be_a(::Regexp)
    expect(filtered_settings['_secure_my_secure_setting'].to_s).to eql %r{^(.*\\.|)example\\.com/abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz}.to_s # rubocop:disable Layout/LineLength
  end

  it 'can decrypt a Date' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'fhM8yqBFFrL3KBM8d0dqzE0uCANcs952XDBrC63z' \
                                           'ddviCGMmNn2yp5072lqNQ1VkbGBGGvr+gM7knQvU' \
                                           '4+AJFpWRvw0ZXuPogrA6o3fQ+XbBZtMxY5REs01i' \
                                           '2/hgT8qfysI5yDbKLQfDkEUZDO/1g7gopcgVWjDx' \
                                           'vYjQaTXzZoTafnzFFyonHTt24yKig+SZVKFfiSNK' \
                                           'epm2Ah4O8zy8Kxqsnk2BCHldsptPJ79EF6Mpxbhr' \
                                           'YWKs0wO9GatR0WZPhAGfEnCC9Jkbm0Vq7XqxCRZf' \
                                           'gIf0zUDWNIO6+IG7cBNUu+ZJZGE0OgMT+a9r2+hv' \
                                           'YvxId4kRn4RDzCchQ3PBhg==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to     be_a(::Date)
    expect(filtered_settings['_secure_my_secure_setting']).to eql ::Date.new(2020, 1, 1)
  end

  it 'can decrypt a Time' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'TDkLRbW/vNs8EH8R0dD+Zuuwx7OZQjzJ5UdImpG1' \
                                           'ztadmKXg/A2OXZwPThiea8NChJ8PlLkNhVdGClHh' \
                                           'TnVfJI2/4AqOdt0PklcfZ6K0LdvkeSXG3GG0CCVO' \
                                           'C8Dre+cwU+luIzRpoqIwgc9Z6bGO2rXFVm8ffZIA' \
                                           'JLv09JZ81cz1kdxnI+YR2q6cpoAGp5nFAx7Bb2wl' \
                                           'baahqDyZhhx63feHb4smDwu7V3V7pxGp+LZn1yRj' \
                                           'SrwtD3xEEQBnzeqNGgLfN/aiYFsdQZby7SEcYyQZ' \
                                           'YGSC40kTW/gQMQI1d9m767mDhO8e7r++ec6ZDs+I' \
                                           'HsN2D8UjXB7GnWFF4wrxHA==',
          },
          decryption_keys:   { __default: './spec/spec_key' },
        )

    expect(filtered_settings['_secure_my_secure_setting']).to     be_a(::Time)
    expect(filtered_settings['_secure_my_secure_setting']).to eql ::Time.utc(2020,
                                                                             1,
                                                                             1,
                                                                             0,
                                                                             0,
                                                                             0)
  end

  it 'warns when attempting to decrypt an unpermitted class type via Public Key' do
    expect {
      DecryptionFilter.execute(
        secure_key_prefix: '_secure_',
        data:              {
          '_secure_my_secure_setting' => 'm8McltRqgOJK5OCI6t6pfnbSIovnWOMyFy0RdQUw' \
                                         'xP4ea6gloTy8RbUoKlmPajnlYBFt7BlVeWW+xk/t' \
                                         's2+pGnI8d1+waAqxtwpNOgRdM18x47DUaFkojkLQ' \
                                         'f6VbtzfAe3Ruy8ZhDMN44K3M50pZhpwNauntzypr' \
                                         'DJtc8AXSI2wMBQPc5b2gk4C0rXYVMuSQmV/NDxMo' \
                                         'BI7xIH2JGGNmAwStZqiK/kQrMTj5aZKJIr+GKS3N' \
                                         'hpWzJriT8X934MyolmwPEBUwUTUSu/jUNWuMUjBH' \
                                         'w/Xc3YkiBuGJK8UzshX3oFGwLMzQn1gxkFENAIgh' \
                                         'ZYScPfuJ5A1fcX5CbUAk7w==',
        },
        decryption_keys:   { __default: './spec/spec_key' },
      )
    }
      .to \
        raise_error(::Chamber::Errors::DisallowedClass)
          .with_message(include('Tried to load unspecified class: Symbol'))
  end

  it 'warns when attempting to decrypt an unpermitted class type via SSL' do
    expect {
      DecryptionFilter.execute(
        secure_key_prefix: '_secure_',
        data:              {
          '_secure_my_secure_setting' => 'QbDa3B75HTzeY9419VbSd3pivmE9hXQUeNIu2Tou' \
                                         'lyLB5eCs13w7VkhKBSq5YO7dHqTuBiktVPR9bECr' \
                                         'xQsH2atXKn3Dnfm2CnWNQYGVo5QZzFP+NfnlOXhg' \
                                         'xvjTj6RoYeG932MO3oqb7fjxvb3FlPDOzE7bscOd' \
                                         'gbho4JHPKqFlKavTWgJa15fxJnzNmsh4WvtYe9yA' \
                                         'nqpHDc7M3z4v2EgR+Gfm/pYsDeHJRUpxhUJzTDn9' \
                                         'B1tmUnPOPYwfb7przIlrDsk+sFdPvGK7YAMSVz8X' \
                                         'c1nxq1J16Cie4ZWQentBitWAmF1EP9dvYeNyjSSe' \
                                         'qxLaF+YjLBa/oYgBsShPbA==#JMmY1z4T+0k9han' \
                                         'nTXqcig==#3G5bfeHFNQQCdXLXzeihFIhZx1b4Lf' \
                                         'Hac1kA2gQFw03MFx2yA3fKTt3+mIwOK1+GBObddg' \
                                         'qeHVx4e4hmxPj/2pfnSduEgvNRiZ7V7qnR0n/J6c' \
                                         'h675rkvH7Dp5pNA2gXh5q5OMuT/5J0QvgpU8EhUZ' \
                                         'aMv13z3iPI/zMMldyVeJCxKCd8pAQhUgOUe6RAcw' \
                                         '45',
        },
        decryption_keys:   { __default: './spec/spec_key' },
      )
    }
      .to \
        raise_error(::Chamber::Errors::DisallowedClass)
          .with_message(include('Tried to load unspecified class: Symbol'))
  end

  it 'can decrypt large encrypted data' do
    filtered_settings = \
      DecryptionFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_my_secure_setting' => 'AcMY7ALLoGZRakL3ibyo2WB438ipdMDIjsa4SCDB' \
                                           'P2saOY63AD3C/SZanexlYDQoYoYC0V5J5EvKHgGM' \
                                           'DAU8qnp9LjzU5VCwJ3SVRGz3J0c7LXgTlC585Lgy' \
                                           '8LX+/yjYFm4D13hlMvvsoI35Bo8EVkTSU2+0gRSj' \
                                           'RpQJeK1o7az5+fBuNmFipevA4YfLnarnpwo2d2oO' \
                                           '+BqStI2QQI1UWwN2R04rvOdHoEzA6DLsdvYX+QTK' \
                                           'Dk4K5oSKXfuMBvzOCaCGT75cmt85ZY7XZnwbKi6c' \
                                           '4mtL1ajrCr8sQFTA/GyG1EiYLFp1uQco0m2/S9yF' \
                                           'f26REjax4ZE6O/ilXgT6xg==#YAm25swWRQx4ip1' \
                                           'RjVzpGQ==#vRGvgjErI+dATM4UOtFkkgefFpFTvx' \
                                           'GpHN0gRbf1VCO4K07eqAQPb46BDI67a8iNum9cBp' \
                                           'hes7oGmuNnUvBg4JiZhKsXnolcRWdITDVh/XYNio' \
                                           'XRmesvj4x+tY0FVhkLV2zubRVfC7CDJgin6wRHP+' \
                                           'bcZhICDD2YqB+XRS4ou66UeaiGA4eV4G6sPIo+DP' \
                                           'jDM3m8JFnuRFMvGk73wthbN4MdAp9xONt5wfobJU' \
                                           'iUR11k2iAqwhx7Wyj0imz/afI8goDTdMfQt3VDOY' \
                                           'qYG3y2AcYOfsOL6m0GtQRlKvtsvw+m8/ICwSGiL2' \
                                           'Loup0j/jDGhFi1lwf4ded8aSwyS+2/Ks9C008dsJ' \
                                           'wpR1SxJ59z1KSzdQcTcrJTnxd+2qpOVVIoaRGud2' \
                                           'tSV+5wKXy9dWRflLsjEtBRFReFurTVQPodjDy+Lh' \
                                           's452/O/+KAJOXMKeYegCGOe8z9tLD3teljjTyJPe' \
                                           'W/1FE3+tP3G3HJAV4sgoO0YwhNY1Nji56igCl3Uv' \
                                           'EPnEQcJgu0w/+dqSreqwp6TqaqXY3lzr8vi733lt' \
                                           'i4nss=',
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
