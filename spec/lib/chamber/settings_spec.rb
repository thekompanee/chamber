# frozen_string_literal: true
require 'rspectacular'
require 'chamber/settings'

module    Chamber
describe  Settings do
  it 'can verify that it is equal to another Settings object' do
    settings        = Settings.new(settings:   { setting: 'value' },
                                   namespaces: ['good'])
    other_settings  = Settings.new(settings:   { setting: 'value' },
                                   namespaces: ['good'])

    expect(settings).to eql other_settings
  end

  it 'does not consider itself equal if the namespaces are not equal' do
    settings        = Settings.new(settings:   { setting: 'value' },
                                   namespaces: ['good'])
    other_settings  = Settings.new(settings:   { setting: 'value' },
                                   namespaces: ['bad'])

    expect(settings).not_to eql other_settings
  end

  it 'does not consider itself equal if the settings are not equal' do
    settings        = Settings.new(settings:   { setting: 'value' },
                                   namespaces: ['good'])
    other_settings  = Settings.new(settings:   { setting: 'value 1' },
                                   namespaces: ['good'])

    expect(settings).not_to eql other_settings
  end

  it 'knows how to convert itself into an environment hash' do
    settings = Settings.new(settings: {
                              my_setting: 'value',
                              level_1:    {
                                level_2: {
                                  some_setting: 'hello',
                                  another:      'goodbye',
                                },
                                body:    'gracias',
                              },
                              there:      'was not that easy?',
                            })

    expect(settings.to_environment).to  eql(
      'MY_SETTING'                   => 'value',
      'LEVEL_1_LEVEL_2_SOME_SETTING' => 'hello',
      'LEVEL_1_LEVEL_2_ANOTHER'      => 'goodbye',
      'LEVEL_1_BODY'                 => 'gracias',
      'THERE'                        => 'was not that easy?',
    )
  end

  it 'sorts environment variables by name when converted to an environment hash so ' \
     'that they are easier to parse for humans' do

    settings = Settings.new(settings: {
                              'C' => 'value',
                              'D' => 'value',
                              'A' => 'value',
                              'E' => 'value',
                              'B' => 'value',
                            })

    expect(settings.to_environment.to_a).to eql([
                                                  %w{A value},
                                                  %w{B value},
                                                  %w{C value},
                                                  %w{D value},
                                                  %w{E value},
                                                ])
  end

  it 'can convert itself into a string' do
    settings = Settings.new(settings: {
                              my_setting: 'value',
                              level_1:    {
                                level_2: {
                                  some_setting: 'hello',
                                  another:      'goodbye',
                                },
                                body:    'gracias',
                              },
                              there:      'was not that easy?',
                            })

    expect(settings.to_s).to eql %w{
                                   LEVEL_1_BODY="gracias"
                                   LEVEL_1_LEVEL_2_ANOTHER="goodbye"
                                   LEVEL_1_LEVEL_2_SOME_SETTING="hello"
                                   MY_SETTING="value"
                                   THERE="was not that easy?"
                                 }.join(' ')
  end

  it 'can convert itself into a string with custom options' do
    settings = Settings.new(settings: {
                              my_setting: 'value',
                              level_1:    {
                                level_2: {
                                  some_setting: 'hello',
                                  another:      'goodbye',
                                },
                                body:    'gracias',
                              },
                              there:      'was not that easy?',
                            })

    settings_string = settings.to_s hierarchical_separator: '/',
                                    pair_separator:         "\n",
                                    value_surrounder:       "'",
                                    name_value_separator:   ': '

    expect(settings_string).to eql <<-HEREDOC.chomp
LEVEL_1/BODY: 'gracias'
LEVEL_1/LEVEL_2/ANOTHER: 'goodbye'
LEVEL_1/LEVEL_2/SOME_SETTING: 'hello'
MY_SETTING: 'value'
THERE: 'was not that easy?'
HEREDOC
  end

  it 'can merge itself with a hash' do
    settings        = Settings.new(settings: { setting: 'value' })
    other_settings  = { other_setting: 'another value' }

    merged_settings = settings.merge(other_settings)

    expect(merged_settings).to eq('setting'       => 'value',
                                  'other_setting' => 'another value')
  end

  it 'can merge itself with Settings' do
    settings       = Settings.new(settings:   { setting:       'value' },
                                  namespaces: ['good'])
    other_settings = Settings.new(settings:   { other_setting: 'another value' },
                                  namespaces: ['bad'])

    merged_settings = settings.merge(other_settings)

    expect(merged_settings).to eql Settings.new(settings:   {
                                                  setting:       'value',
                                                  other_setting: 'another value',
                                                },
                                                namespaces: %w{good bad})
  end

  it 'does not manipulate the existing Settings but instead returns a new one' do
    settings       = Settings.new(settings:   { setting:       'value' })
    other_settings = Settings.new(settings:   { other_setting: 'another value' })

    merged_settings = settings.merge(other_settings)

    expect(merged_settings.object_id).not_to eql settings.object_id
    expect(merged_settings.object_id).not_to eql other_settings.object_id
  end

  it 'can convert itself into a hash' do
    settings = Settings.new(settings: { setting: 'value' })

    expect(settings.to_hash).to     eql('setting' => 'value')
    expect(settings.to_hash).to     be_a Hash
    expect(settings.to_hash).not_to be_a Hashie::Mash
  end

  it 'can convert itself into a hash with flattened names' do
    settings = Settings.new(settings: {
                              my_setting: 'value',
                              level_1:    {
                                level_2: {
                                  some_setting: 'hello',
                                  another:      'goodbye',
                                },
                                body:    'gracias',
                              },
                              there:      'was not that easy?',
                            })

    expect(settings.to_flattened_name_hash).to eql(
      %w{my_setting}                   => 'value',
      %w{level_1 level_2 some_setting} => 'hello',
      %w{level_1 level_2 another}      => 'goodbye',
      %w{level_1 body}                 => 'gracias',
      %w{there}                        => 'was not that easy?',
    )
    expect(settings.to_flattened_name_hash).to     be_a Hash
    expect(settings.to_flattened_name_hash).not_to be_a Hashie::Mash
  end

  it 'does not allow manipulation of the internal setting hash when converted to ' \
     'a Hash' do

    settings = Settings.new(settings: { setting: 'value' })

    settings_hash = settings.to_hash
    settings_hash['setting'] = 'foo'

    expect(settings.__send__(:data).object_id).not_to eql settings_hash.object_id
    expect(settings.setting).to eql 'value'
  end

  it 'allows messages to be passed through to the underlying data' do
    settings = Settings.new(settings: { setting: 'value' })

    expect(settings.setting).to eql 'value'
  end

  it 'will still raise an error if the underlying data does not respond to it' do
    settings = Settings.new(settings: { setting: 'value' })

    expect { settings.unknown }.to raise_error NoMethodError
  end

  it 'can notify properly whether it responds to messages if the underlying data does' do
    settings = Settings.new(settings: { setting: 'value' })

    expect(settings.respond_to?(:setting)).to be_a TrueClass
  end

  it 'only includes namespaced data if any exists' do
    settings = Settings.new(settings:   {
                              namespace_value:       {
                                namespace_setting: 'value',
                              },
                              other_namespace_value: {
                                other_namespace_setting: 'value',
                              },
                              non_namespace_setting: 'other value',
                            },
                            namespaces: %w{namespace_value other_namespace_value})

    expect(settings).to eq('namespace_setting'       => 'value',
                           'other_namespace_setting' => 'value')
  end

  it 'can decrypt a setting if it finds a secure key' do
    settings = Settings.new(
      settings:       {
        _secure_my_encrypted_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                      'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                      'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                      'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                      'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                      '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                      'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                      'p2Y0H1jPgGkBKQJKArfQ==',
      },
      decryption_key: './spec/spec_key',
    )

    expect(settings).to eq('my_encrypted_setting' => 'hello')
  end

  it 'can encrypt a setting if it finds a secure key' do
    settings = Settings.new(settings:       {
                              _secure_my_encrypted_setting: 'hello',
                            },
                            encryption_key: './spec/spec_key.pub',
                            pre_filters:    [],
                            post_filters:   [Filters::EncryptionFilter])

    expect(settings._secure_my_encrypted_setting).to match \
      Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'can encrypt a settings without explicitly having to have a filter passed' do
    settings = Settings.new(settings:       {
                              _secure_my_encrypted_setting: 'hello',
                            },
                            decryption_key: './spec/spec_key',
                            encryption_key: './spec/spec_key.pub')

    expect(settings).to eq('my_encrypted_setting' => 'hello')

    secure_settings = settings.secure

    expect(secure_settings.my_encrypted_setting).to match \
      Filters::EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'can check if it is equal to other items which can be converted into hashes' do
    settings = Settings.new(settings: { setting: 'value' })

    expect(settings).to eq('setting' => 'value')
  end

  it 'can filter securable settings' do
    settings = Settings.new(
      settings:       {
        _secure_my_encrypted_setting:   'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                        'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                        'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                        'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                        'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                        '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                        'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                        'p2Y0H1jPgGkBKQJKArfQ==',
        _secure_my_unencrypted_setting: 'nifty',
        my_insecure_setting:            'goodbye',
      },
      decryption_key: './spec/spec_key',
    )

    secured_settings = settings.securable

    expect(secured_settings.my_encrypted_setting).to    eql 'hello'
    expect(secured_settings.my_unencrypted_setting).to  eql 'nifty'
    expect(secured_settings.my_insecure_setting?).to    eql false
  end

  it 'can filter unencrypted settings' do
    settings = Settings.new(
      settings:       {
        _secure_my_encrypted_setting:   'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                        'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                        'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                        'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                        'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                        '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                        'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                        'p2Y0H1jPgGkBKQJKArfQ==',
        _secure_my_unencrypted_setting: 'nifty',
        my_insecure_setting:            'goodbye',
      },
      decryption_key: './spec/spec_key',
    )

    secured_settings = settings.insecure

    expect(secured_settings.my_encrypted_setting?).to   eql false
    expect(secured_settings.my_unencrypted_setting).to  eql 'nifty'
    expect(secured_settings.my_insecure_setting?).to    eql false
  end

  it 'raises an exception when it accesses a value which cannot be decrypted' do
    settings = Settings.new(
      settings: {
        _secure_my_encrypted_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                      'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                      'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                      'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                      'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                      '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                      'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                      'p2Y0H1jPgGkBKQJKArfQ==',
      },
    )

    expect { settings.my_encrypted_setting }.
    to raise_error Chamber::Errors::DecryptionFailure
  end

  it 'prefers environment variable values over encrypted values' do
    ENV['MY_ENCRYPTED_SETTING']                       = 'my env setting'
    ENV['ENCRYPTED_GROUP_MY_ENCRYPTED_GROUP_SETTING'] = 'my env group'

    settings = Settings.new(
      settings: {
        _secure_my_encrypted_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYTha' \
                                      'V4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4ak' \
                                      'un6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkE' \
                                      'jY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8M' \
                                      'v4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/' \
                                      '1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86' \
                                      'wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmU' \
                                      'p2Y0H1jPgGkBKQJKArfQ==',
        encrypted_group:              {
          _secure_my_encrypted_group_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdn' \
                                              'MoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3Fx' \
                                              'ptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEA' \
                                              'QLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUT' \
                                              'f34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5k' \
                                              'LAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlz' \
                                              'pKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgU' \
                                              'Kc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84Xz' \
                                              'mUp2Y0H1jPgGkBKQJKArfQ==',
        },
      },
    )

    expect(settings.my_encrypted_setting).to                       eql 'my env setting'
    expect(settings.encrypted_group.my_encrypted_group_setting).to eql 'my env group'

    ENV['MY_ENCRYPTED_SETTING']                       = nil
    ENV['ENCRYPTED_GROUP_MY_ENCRYPTED_GROUP_SETTING'] = nil
  end
end
end
