require 'rspectacular'
require 'chamber/filters/failed_decryption_filter'

module    Chamber
module    Filters
describe  FailedDecryptionFilter do
  it 'raises an exception if any of the settings are not decrypted' do
    expect do
      FailedDecryptionFilter.execute(
        data: {
          _secure_my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                                     'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                                     '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                                     'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                                     'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                                     'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                                     'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
        },
      )
    end.
    to raise_error Chamber::Errors::DecryptionFailure
  end

  it 'does not raise an exception if it is not a secure key' do
    expect do
      FailedDecryptionFilter.execute(
        data: {
          my_secure_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4m' \
                             'psspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ5' \
                             '7m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXz' \
                             'nf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZD' \
                             'wS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXW' \
                             'S7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kK' \
                             'TcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==',
        },
      )
    end.
    not_to raise_error
  end

  it 'does not raise an exception if it is not a secure value' do
    expect do
      FailedDecryptionFilter.execute(
        data: {
          _secure_my_secure_setting: 'hello',
        },
      )
    end.
    not_to raise_error
  end
end
end
end
