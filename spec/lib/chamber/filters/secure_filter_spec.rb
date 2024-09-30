# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/secure_filter'

module    Chamber
module    Filters
describe  SecureFilter do
  it 'returns values which are marked as "secure"' do
    filtered_settings = SecureFilter.execute(secure_key_prefix: '_secure_',
                                             data:              {
                                               '_secure_my_secure_setting' => 'hello',
                                             })

    expect(filtered_settings['_secure_my_secure_setting']).to match 'hello'
  end

  it 'does not return values which are not marked as "secure"' do
    filtered_settings = SecureFilter.execute(secure_key_prefix: '_secure_',
                                             data:              {
                                               'my_secure_setting' => 'hello',
                                             })

    expect(filtered_settings['my_secure_setting']).to be nil
  end

  it 'properly returns values even if they are mixed and deeply nested' do
    filtered_settings = SecureFilter.execute(secure_key_prefix: '_secure_',
                                             data:              {
                                               '_secure_setting' => 'hello',
                                               'secure_setting'  => 'goodbye',
                                               'secure_group'    => {
                                                 '_secure_nested_setting'  => 'movie',
                                                 'insecure_nested_setting' => 'dinner',
                                               },
                                             })

    expect(filtered_settings['_secure_setting']).to                         eql 'hello'
    expect(filtered_settings['secure_setting']).to                          be(nil)
    expect(filtered_settings['secure_group']['_secure_nested_setting']).to  eql 'movie'
    expect(filtered_settings['secure_group']['insecure_nested_setting']).to be(nil)
  end
end
end
end
