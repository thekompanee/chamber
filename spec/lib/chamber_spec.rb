# frozen_string_literal: true

require 'rspectacular'
require 'chamber'
require 'fileutils'

FileUtils.mkdir_p('/tmp/chamber/settings') unless File.exist?('/tmp/chamber/settings')

File.open('/tmp/chamber/settings.yml', 'w+') do |file|
  file.puts <<-HEREDOC
test:
  my_setting: my_value
  my_boolean: false
  my_dynamic_setting: <%= 1 + 1 %>
  my_ftp_url: ftp://username:password@127.0.0.1
  another_level:
    setting_one: 1
    setting_two: 2
    level_three:
      an_array:
        - item 1
        - item 2
        - item 3
      a_scalar: 'hello'
  HEREDOC
end

File.open('/tmp/chamber/secure_settings_with_namespaces.yml', 'w+') do |file|
  file.puts <<-HEREDOC
development:
  sub_key:
    sub_sub_key:
      _secure_development_setting: RPaB5BEuo4Ht+97GA41GSD+fW4xABbJ/CvDZtnh/UqpCoiAG9MlASlMsCrVEf6OH075Sm1X33Q3uJEoKEtdooqFF6rgUe9AV4rp1nrclFCv9/bJJEemeV3tVMPMFqItxxIdGzMMYE9CuiL74TCQzcnvadOl1qWlQ4y/q+l5t8YEziB6IZSKYXQJw8SUHBtTitfH/lnXqh27f2U6Y0WSlDC+LJHJLRo4x/0+Sc5CTRl78eGedctGjMjRCrzg7MKvKzaKx2Quw7MnG9d/eOy05/uLTho/SosEjL6wTHhMJMzWfeC5LPVuM4v9haSRZseZTkYeLczOpjn2W/PlOlvnWTw==

production:
  sub_key:
    sub_sub_key:
      _secure_production_setting: P1dbC/J3kALefhxbnlYQiJVFXnAQTnZIs8Te2Wuz+HtS6LaOgHPUMal8h5Utx9ezPDHWRpZDRuXDyKLXoikp7TrQdfR2bOva6TSMLK2XT0U5aCWhwXphYsTvfXl22IDsvYP38SUZqK7BXyChZpaVw7tj8634MTEsXdjEdHdIzEWcO/pWJ2Xh2f71+s9FkfEQH1Mj6Tyd2Hhp0iczJDi5wbJ7EW1ivCUrhCnxQQR7Q8+exUx+inzOEyq0NHJ6GfFXf7cHAV4jPYXJCvBqk9TG/7rVVUKivUZeLrPkmiSorVUZgzzL8MARlWCJABs+AhXEZko42rc/jfi9O/ONMLdy7Q==

other:
  sub_key:
    sub_sub_key:
      _secure_other_setting: BZtWwj2KAuwxDCMoHvGRQmZwonh25vDxQUYXSNEUaxAx2ySVKJf5BsD166m1NUCpDTNr2u/s9u3TEQJCDaji6QU3zNshrs9JCeyhs2ti7AR/ZoY2GYAOvATYIM4Hc8EsrlQjf+TWRwgLOwjd0QWnyUWPVPrHcS+vk13rkkoOe03fVhb3gMuqQJn9Mlw08qW7oAFfQc3Fy/TgvmkSekMCtEbhNpa75xbk6RvDhTZKpHPXTq9/6jDXlukFo4MYX3zQ6AeGM8Rd+QsvwAWrlXhOTZ3qx8gLFuGWaD6GgoUDO5MoBZkSni4Ej1n/sBsbmF0jFY+EM6Z5Ajhn4VWoMerKfw==
  HEREDOC
end

File.open('/tmp/chamber/secure.yml', 'w+') do |file|
  file.puts <<-HEREDOC
test:
  _secure_my_encrpyted_setting: cJbFe0NI5wknmsp2fVgpC/YeBD2pvcdVD+p0pUdnMoYThaV4mpsspg/ZTBtmjx7kMwcF6cjXFLDVw3FxptTHwzJUd4akun6EZ57m+QzCMJYnfY95gB2/emEAQLSz4/YwsE4LDGydkEjY1ZprfXznf+rU31YGDJUTf34ESz7fsQGSc9DjkBb9ao8Mv4cI7pCXkQZDwS5kLAZDf6agy1GzeL71Z8lrmQzk8QQuf/1kQzxsWVlzpKNXWS7u2CJ0sN5eINMngJBfv5ZFrZgfXc86wdgUKc8aaoX8OQA1kKTcdgbE9NcAhNr1+WfNxMnz84XzmUp2Y0H1jPgGkBKQJKArfQ==
  HEREDOC
end

File.open('/tmp/chamber/settings-blue.yml', 'w+') do |file|
  file.puts <<-HEREDOC
test:
  my_other_setting: my_other_value
  another_level:
    setting_one: 3
other:
  everything: works
  HEREDOC
end

File.open('/tmp/chamber/settings/some_settings_file.yml', 'w+') do |file|
  file.puts <<-HEREDOC
blue:
  my_settings_for_inline_namespace: my_value_for_inline_namespace
my_non_inline_namespaced_setting: my_value_for_non_inline_namespace
  HEREDOC
end

File.open('/tmp/chamber/settings/sub_settings.yml', 'w+') do |file|
  file.puts <<-HEREDOC
sub_settings:
  my_sub_setting: my_sub_setting_value
  HEREDOC
end

File.open('/tmp/chamber/settings/sub_settings-blue.yml', 'w+') do |file|
  file.puts <<-HEREDOC
sub_settings:
  my_namespaced_sub_setting: my_namespaced_sub_setting_value
  HEREDOC
end

File.open('/tmp/chamber/settings/only_namespaced_settings-blue.yml', 'w+') do |file|
  file.puts <<-HEREDOC
only_namespaced_sub_settings:
  another_sub_setting: namespaced
  HEREDOC
end

describe Chamber do
  before(:each) { Chamber.load(basepath: '/tmp/chamber') }

  it 'knows how to load itself with a path string' do
    Chamber.load(basepath: '/tmp/chamber')

    expect(Chamber.configuration.basepath.to_s).to eql '/tmp/chamber'
  end

  it 'knows how to load itself with a path object' do
    Chamber.load(basepath: Pathname.new('/tmp/chamber'))

    expect(Chamber.configuration.basepath.to_s).to eql '/tmp/chamber'
  end

  it 'processes settings files through ERB before YAML' do
    expect(Chamber[:test][:my_dynamic_setting]).to be 2
  end

  it 'can access settings through a hash-like syntax' do
    expect(Chamber[:test][:my_setting]).to eql 'my_value'
  end

  it 'can access the settings via "env"' do
    expect(Chamber.env[:test][:my_setting]).to eql 'my_value'
  end

  it 'prefers values stored in environment variables over those in the YAML files' do
    ENV['TEST_MY_SETTING']                         = 'some_other_value'
    ENV['TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'] = '[1, 2, 3]'

    Chamber.load(basepath: '/tmp/chamber')
    expect(Chamber[:test][:my_setting]).to eql 'some_other_value'
    expect(Chamber[:test][:another_level][:level_three]['an_array']).to eql [1, 2, 3]
    expect(Chamber[:test][:my_dynamic_setting]).to be 2

    ENV.delete 'TEST_MY_SETTING'
    ENV.delete 'TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'
  end

  it 'can load files based on the namespace passed in' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber[:other][:everything]).to        eql 'works'
    expect(Chamber[:test][:my_dynamic_setting]).to be  2
  end

  it 'loads multiple namespaces if it is called twice' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   first_namespace_call:  -> { :first },
                   second_namespace_call: -> { :second },
                 })

    expect(Chamber.namespaces.to_a).to eql %w{first second}
  end

  # rubocop:disable Lint/DuplicateHashKey
  it 'does not load the same namespace twice' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   first_namespace_call: -> { :first },
                   first_namespace_call: -> { :first },
                 })

    expect(Chamber.namespaces.to_a).to eql %w{first}
  end
  # rubocop:enable Lint/DuplicateHashKey

  it 'will load settings files which are only namespaced' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber[:only_namespaced_sub_settings][:another_sub_setting]).to eql 'namespaced'
  end

  it 'clears all settings each time the settings are loaded' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber[:only_namespaced_sub_settings][:another_sub_setting]).to eql 'namespaced'

    Chamber.load(basepath: '/tmp/chamber')

    expect(Chamber[:only_namespaced_sub_settings]).to be_nil
  end

  it 'does not raise an exception if a namespaced file does not exist' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   non_existant_namespace: -> { false },
                 })

    expect { Chamber.load(basepath: '/tmp/chamber') }.not_to raise_error
  end

  it 'merges (not overrides) subsequent settings' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber[:test][:my_setting]).to                eql 'my_value'
    expect(Chamber[:test][:my_other_setting]).to          eql 'my_other_value'
    expect(Chamber[:test][:another_level][:setting_one]).to be 3
  end

  it 'loads YAML files from the "settings" directory under the base directory if ' \
     'any exist' do
    expect(Chamber[:sub_settings][:my_sub_setting]).to eql 'my_sub_setting_value'
  end

  it 'does not load YAML files from the "settings" directory if it is namespaced' do
    expect(Chamber['sub_settings-namespaced']).to be_nil
  end

  it 'loads namespaced YAML files in the "settings" directory if they correspond to ' \
     'a value namespace' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber['sub_settings']['my_namespaced_sub_setting']).to eql 'my_namespaced_sub_setting_value'
  end

  it 'loads namespaced settings if they are inline in a non-namespaced filename' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber['my_settings_for_inline_namespace']).to eql 'my_value_for_inline_namespace'
  end

  it 'does not load non-namespaced data from a file if inline namespaces are found' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber['my_non_inline_namespaced_setting']).not_to eql 'my_value_for_non_inline_namespace'
  end

  it 'loads the entire inline namespaced file if no namespaces are passed in since ' \
     'it does not know they are namespaced' do
    Chamber.load(basepath: '/tmp/chamber')

    expect(Chamber['blue']['my_settings_for_inline_namespace']).to eql 'my_value_for_inline_namespace'
    expect(Chamber['my_non_inline_namespaced_setting']).to         eql 'my_value_for_non_inline_namespace'
  end

  # rubocop:disable Lint/DuplicateHashKey
  it 'can convert the settings to their environment variable versions' do
    Chamber.load(basepath: '/tmp/chamber')

    expect(Chamber.to_environment).to eql(
                                        'SUB_SETTINGS_MY_SUB_SETTING'             => 'my_sub_setting_value',
                                        'TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY' => '["item 1", "item 2", "item 3"]',
                                        'TEST_ANOTHER_LEVEL_LEVEL_THREE_A_SCALAR' => 'hello',
                                        'TEST_ANOTHER_LEVEL_SETTING_ONE'          => '1',
                                        'TEST_ANOTHER_LEVEL_SETTING_TWO'          => '2',
                                        'TEST_MY_DYNAMIC_SETTING'                 => '2',
                                        'TEST_MY_SETTING'                         => 'my_value',
                                        'TEST_MY_FTP_URL'                         => 'ftp://username:password@127.0.0.1',
                                        'TEST_MY_SETTING'                         => 'my_value',
                                        'TEST_MY_BOOLEAN'                         => 'false',
                                        'BLUE_MY_SETTINGS_FOR_INLINE_NAMESPACE'   => 'my_value_for_inline_namespace',
                                        'MY_NON_INLINE_NAMESPACED_SETTING'        => 'my_value_for_non_inline_namespace',
                                      )
  end
  # rubocop:enable Lint/DuplicateHashKey

  it 'can handle decrypting values using the key for the namespace if it exists' do
    Chamber.load(namespaces: %w{development production},
                 files:      %w{/tmp/chamber/secure_settings_with_namespaces.yml},
                 rootpath:   './spec/fixtures/keys/real/',
                 basepath:   '/tmp/chamber/')

    expect(Chamber.env[:sub_key][:sub_sub_key][:development_setting]).to eql 'hello development'
    expect(Chamber.env[:sub_key][:sub_sub_key][:production_setting]).to  eql 'hello production'

    Chamber.load(namespaces: %w{other},
                 files:      %w{/tmp/chamber/secure_settings_with_namespaces.yml},
                 rootpath:   './spec/fixtures/keys/real/',
                 basepath:   '/tmp/chamber/')

    expect(Chamber.env[:sub_key][:sub_sub_key][:other_setting]).to eql 'hello other'
  end

  it 'can explicitly specify files without specifying a basepath' do
    Chamber.load(files: ['/tmp/chamber/settings.yml'])

    expect(Chamber.filenames).to  eql ['/tmp/chamber/settings.yml']
    expect(Chamber.to_hash).to    include(
                                    'test' => include(
                                                'my_setting' => 'my_value',
                                                'my_ftp_url' => 'ftp://username:password@127.0.0.1',
                                              ),
                                  )
  end

  it 'ignores the basepath if file patterns are explicitly passed in' do
    Chamber.load(basepath: '/tmp/chamber',
                 files:    'settings.yml')

    expect(Chamber.filenames).to eql ['settings.yml']
  end

  it 'can render itself as a string even if it has not been loaded' do
    Chamber.load(basepath: '/')

    expect(Chamber.to_s).to eql ''
  end

  it 'can determine settings even if it has not been loaded' do
    Chamber.load(basepath: '/')

    expect(Chamber.to_hash).to eql({})
  end

  it 'can unencrpyt an already encrpyted value if it has access to the private key' do
    Chamber.load(files:           '/tmp/chamber/secure.yml',
                 decryption_keys: './spec/spec_key')

    expect(Chamber[:test][:my_encrpyted_setting]).to eql 'hello'
  end
end
