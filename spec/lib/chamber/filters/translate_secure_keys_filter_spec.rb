# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/translate_secure_keys_filter'

module    Chamber
module    Filters
describe  TranslateSecureKeysFilter do
  it 'will translate keys if they start with "_secure_"' do
    filtered_settings = TranslateSecureKeysFilter.execute(
      secure_key_prefix: '_secure_',
      data: {
        _secure_my_secure_setting: 'hello',
      },
    )

    expect(filtered_settings.my_secure_setting).to eql 'hello'
  end

  it 'will not translate keys if they do not start with "_secure_"' do
    filtered_settings = TranslateSecureKeysFilter.execute(
      secure_key_prefix: '_secure_',
      data: {
        my_secure_setting: 'hello',
      },
    )

    expect(filtered_settings.my_secure_setting).to eql 'hello'
  end

  it 'will not translate the key if it starts with "secure"' do
    filtered_settings = TranslateSecureKeysFilter.execute(
      secure_key_prefix: '_secure_',
      data: {
        secure_setting: 'hello',
      },
    )

    expect(filtered_settings.secure_setting).to eql 'hello'
  end
end
end
end
