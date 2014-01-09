require 'rspectacular'
require 'chamber/settings'

class     Chamber
describe  Settings do
  it 'can verify that it is equal to another Settings object' do
    settings        = Settings.new( settings:   {setting: 'value'},
                                    namespaces: ['good'])
    other_settings  = Settings.new( settings:   {setting: 'value'},
                                    namespaces: ['good'])

    expect(settings).to eql other_settings
  end

  it 'does not consider itself equal if the namespaces are not equal' do
    settings        = Settings.new( settings:   {setting: 'value'},
                                    namespaces: ['good'])
    other_settings  = Settings.new( settings:   {setting: 'value'},
                                    namespaces: ['bad'])

    expect(settings).not_to eql other_settings
  end

  it 'does not consider itself equal if the settings are not equal' do
    settings        = Settings.new( settings:   {setting: 'value'},
                                    namespaces: ['good'])
    other_settings  = Settings.new( settings:   {setting: 'value 1'},
                                    namespaces: ['good'])

    expect(settings).not_to eql other_settings
  end

  it 'knows how to convert itself into an environment hash' do
    allow(SystemEnvironment).to receive(:extract_from).
                                and_return(:environment => :development)

    settings = Settings.new(settings: {setting: 'value'})

    expect(settings.to_environment).to  eql(:environment => :development)
    expect(SystemEnvironment).to        have_received(:extract_from).
                                        with(Hashie::Mash.new setting: 'value')
  end

  it 'sorts environment variables by name when converted to an environment hash so that they are easier to parse for humans' do
    allow(SystemEnvironment).to receive(:extract_from).
                                and_return('C' => 'value',
                                           'D' => 'value',
                                           'A' => 'value',
                                           'E' => 'value',
                                           'B' => 'value',)

    settings = Settings.new(settings: { setting: 'value' })

    expect(settings.to_environment.to_a).to eql([['A', 'value'],
                                                 ['B', 'value'],
                                                 ['C', 'value'],
                                                 ['D', 'value'],
                                                 ['E', 'value']])
  end

  it 'can convert itself into a string' do
    allow(SystemEnvironment).to receive(:extract_from).
                                and_return('C' => 'cv',
                                           'D' => 'dv',
                                           'A' => 'av',
                                           'E' => 'ev',
                                           'B' => 'bv',)

    settings = Settings.new(settings: { setting: 'value' })

    expect(settings.to_s).to eql %Q{A="av" B="bv" C="cv" D="dv" E="ev"}
  end

  it 'can merge itself with a hash' do
    settings = Settings.new(settings: {setting: 'value'})
    settings.merge!(other_setting: 'another value')

    expect(settings.to_hash).to eql Hashie::Mash.new( setting:        'value',
                                                      other_setting:  'another value')
  end

  it 'can merge itself with Settings' do
    settings       = Settings.new(settings:   {setting:       'value'},
                                  namespaces: ['good'])

    other_settings = Settings.new(settings:   {other_setting: 'another value'},
                                  namespaces: ['bad'])

    settings.merge!(other_settings)

    expect(settings).to eql Settings.new( settings:   {
                                            setting:        'value',
                                            other_setting:  'another value' },
                                          namespaces: ['good', 'bad'])
  end

  it 'can convert itself into a hash' do
    settings = Settings.new(settings: {setting: 'value'})

    expect(settings.to_hash).to     eql('setting' => 'value')
    expect(settings.to_hash).to     be_a Hash
    expect(settings.to_hash).not_to be_a Hashie::Mash
  end

  it 'does not allow manipulation of the internal setting hash when converted to a Hash' do
    settings = Settings.new(settings: {setting: 'value'})

    settings_hash = settings.to_hash
    settings_hash['setting'] = 'foo'

    expect(settings.send(:data).object_id).not_to eql settings_hash.object_id
    expect(settings.setting).to eql 'value'
  end

  it 'allows messages to be passed through to the underlying data' do
    settings = Settings.new(settings: {setting: 'value'})

    expect(settings.setting).to eql 'value'
  end

  it 'will still raise an error if the underlying data does not respond to it' do
    settings = Settings.new(settings: {setting: 'value'})

    expect { settings.unknown }.to raise_error NoMethodError
  end

  it 'can notify properly whether it responds to messages if the underlying data does' do
    settings = Settings.new(settings: {setting: 'value'})

    expect(settings.respond_to?(:setting)).to be_a TrueClass
  end

  it 'only includes namespaced data if any exists' do
    settings = Settings.new(settings:   {
                              namespace_value:        {
                                namespace_setting:        'value' },
                              other_namespace_value:  {
                                other_namespace_setting:  'value' },
                              non_namespace_setting:  'other value'
                            },
                            namespaces: ['namespace_value', 'other_namespace_value'])

    expect(settings.to_hash).to eql('namespace_setting'       => 'value',
                                    'other_namespace_setting' => 'value')
  end

  it 'can decrypt a setting if it finds a secure key' do
    settings = Settings.new(settings:   {
                              _secure_my_encrypted_setting: 'cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ=='
                            },
                            decryption_key: './spec/spec_key')

    expect(settings.to_hash).to eql('my_encrypted_setting' => 'hello')
  end

  it 'can check if it is equal to other items which can be converted into hashes' do
    settings = Settings.new(settings: {setting: 'value'})

    expect(settings).to eq('setting' => 'value')
  end
end
end
