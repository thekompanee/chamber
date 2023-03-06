# frozen_string_literal: true

require 'rspectacular'
require 'chamber/filters/insecure_filter'

module    Chamber
module    Filters
describe  InsecureFilter do
  it 'will return values which are marked as "secure" if they are unencrypted' do
    filtered_settings = InsecureFilter.execute(secure_key_prefix: '_secure_',
                                               data:              {
                                                 '_secure_my_secure_setting' => 'hello',
                                               })

    expect(filtered_settings['_secure_my_secure_setting']).to match 'hello'
  end

  it 'will not return values which are not marked as "secure"' do
    filtered_settings = InsecureFilter.execute(secure_key_prefix: '_secure_',
                                               data:              {
                                                 'my_secure_setting' => 'hello',
                                               })

    expect(filtered_settings['my_secure_setting']).to be_nil
  end

  it 'will properly return values even if they are mixed and deeply nested' do
    filtered_settings = InsecureFilter.execute(secure_key_prefix: '_secure_',
                                               data:              {
                                                 '_secure_setting' => 'hello',
                                                 'secure_setting'  => 'goodbye',
                                                 'secure_group'    => {
                                                   '_secure_nested_setting'  => 'movie',
                                                   'insecure_nested_setting' => 'dinner',
                                                 },
                                               })

    expect(filtered_settings['_secure_setting']).to                         eql 'hello'
    expect(filtered_settings['secure_setting']).to                          be_nil
    expect(filtered_settings['secure_group']['_secure_nested_setting']).to  eql 'movie'
    expect(filtered_settings['secure_group']['insecure_nested_setting']).to be_nil
  end

  it 'will not return values which are encrypted' do
    filtered_settings = \
      InsecureFilter
        .execute(
          secure_key_prefix: '_secure_',
          data:              {
            '_secure_setting'       => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                       'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                       'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                       'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                       'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                       '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                       'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                       'p2Y0H1jPgGkBKQJKArfQ==',
            'secure_setting'        => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                       'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                       'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                       'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                       'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                       '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                       'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                       'p2Y0H1jPgGkBKQJKArfQ==',
            '_secure_other_setting' => 'hello',
            'secure_group'          => {
              '_secure_nested_setting'       => 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvc' \
                                                'dVD+p0pUdnMoYThaV4mpsspg/ZTBtm' \
                                                'jx7kMwcF6cjXFLDVw3FxptTHwzJUd4' \
                                                'akun6EZ57m+QzCMJYnfY95gB2/emEA' \
                                                'QLSz4/YwsE4LDGydkEjY1ZprfXznf+' \
                                                'rU31YGDJUTf34ESz7fsQGSc9DjkBb9' \
                                                'ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1' \
                                                'GzeL71Z8lrmQzk8QQuf/1kQzxsWVlz' \
                                                'pKNXWS7u2CJ0sN5eINMngJBfv5ZFrZ' \
                                                'gfXc86wdgUKc8aaoX8OQA1kKTcdgbE' \
                                                '9NcAhNr1+WfNxMnz84XzmUp2Y0H1jP' \
                                                'gGkBKQJKArfQ==',
              '_secure_other_nested_setting' => 'goodbye',
              'insecure_nested_setting'      => 'dinner',
            },
          },
        )

    expect(filtered_settings['_secure_setting']).to                              be  nil
    expect(filtered_settings['secure_setting']).to                               be  nil
    expect(filtered_settings['_secure_other_setting']).to                        eql 'hello'
    expect(filtered_settings['secure_group']['_secure_nested_setting']).to       be  nil
    expect(filtered_settings['secure_group']['_secure_other_nested_setting']).to eql 'goodbye'
    expect(filtered_settings['secure_group']['insecure_nested_setting']).to      be  nil
  end
end
end
end
