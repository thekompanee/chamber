require 'rspectacular'
require 'chamber/filters/decryption_filter'

module    Chamber
module    Filters
describe  DecryptionFilter do
  it 'will attempt to decrypt values which are marked as "secure"' do
    filtered_settings = DecryptionFilter.execute(
      data:           {
        _secure_my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                                   'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                                   '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                                   'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                                   'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                   'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                                   'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_key: './spec/spec_key')

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'will not attempt to decrypt values which are not marked as "secure"' do
    filtered_settings = DecryptionFilter.execute(
      data:           {
        my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                           'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                           '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                           'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                           'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                           'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                           'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==' },
      decryption_key: './spec/spec_key')

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
      data:           {
        secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mpsspg/ZTBt' \
                        'mjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/em' \
                        'EAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9Djk' \
                        'Bb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxs' \
                        'WVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kKT' \
                        'cdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_key: './spec/spec_key')

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
      data:           {
        _secure_my_secure_setting: 'cJbFe0NI5\wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4' \
                                   'mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ' \
                                   '57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfX' \
                                   'znf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZ' \
                                   'DwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNX' \
                                   'WS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1k' \
                                   'KTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_key: './spec/spec_key')

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
    filtered_settings = DecryptionFilter.execute(data:           {
                                                   _secure_my_secure_setting: 'hello' },
                                                 decryption_key: './spec/spec_key')

    expect(filtered_settings._secure_my_secure_setting).to eql 'hello'
  end

  it 'simply returns the encrypted string if there is no decryption key' do
    filtered_settings = DecryptionFilter.execute(
      data: {
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
    filtered_settings = DecryptionFilter.execute( data: {
                                                    _secure_my_secure_setting: 'rF1MIcLX/Q88gjpHTifI27fJHopDKVTJRvOwF2MZ8kVIrvBhFgLOyQ7JEBiWNBh1yUtR6PeKlB+h44sIL3yKMcZyccX73Mo+CiWxmnjtK4I1QxcJL8OSLa8GQPlSBxoBCykWqerwN0b2oS/jv8umB2j2RyANFYklD3mAxn1LsoTuFPAif+SCLRIGafcHkOywM32qn6HhUpeBChX81JhJpip1gdJmRTGEZjKfR93h1shW0LqLLbdQUwYPOPbnjz7fU7x+d5/ighWTDsmOVyvEiqM0WasFzK+WBUfvo8tQxUymexw/U3B7N/0R/9v6U3l6x7eeIoQ4+lnJK2ULFzVgiw==' },
                                                  decryption_key: './spec/spec_key' )

    expect(filtered_settings._secure_my_secure_setting).to be_a Integer
    expect(filtered_settings._secure_my_secure_setting).to eql  12345
  end
end
end
end
