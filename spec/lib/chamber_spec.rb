# frozen_string_literal: true

require 'rspectacular'
require 'chamber'
require 'fileutils'

FileUtils.mkdir_p '/tmp/chamber/settings' unless File.exist? '/tmp/chamber/settings'

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

  it 'can access the settings through method-based access' do
    expect(Chamber.test.my_setting).to eql 'my_value'
  end

  it 'can access the settings via "env"' do
    expect(Chamber.env.test.my_setting).to eql 'my_value'
  end

  it 'prefers values stored in environment variables over those in the YAML files' do
    ENV['TEST_MY_SETTING'] = 'some_other_value'
    ENV['TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'] = '[1, 2, 3]'

    Chamber.load(basepath: '/tmp/chamber')
    expect(Chamber.test.my_setting).to eql 'some_other_value'
    expect(Chamber.test.another_level.level_three.an_array).to eql [1, 2, 3]
    expect(Chamber.test.my_dynamic_setting).to be 2

    ENV.delete 'TEST_MY_SETTING'
    ENV.delete 'TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'
  end

  it 'can load files based on the namespace passed in' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   my_namespace: -> { 'blue' },
                 })

    expect(Chamber.other.everything).to        eql 'works'
    expect(Chamber.test.my_dynamic_setting).to be  2
  end

  it 'loads multiple namespaces if it is called twice' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   first_namespace_call:  -> { :first },
                   second_namespace_call: -> { :second },
                 })

    expect(Chamber.namespaces.to_a).to eql %w{first second}
  end

  # rubocop:disable Lint/DuplicatedKey
  it 'does not load the same namespace twice' do
    Chamber.load(basepath:   '/tmp/chamber',
                 namespaces: {
                   first_namespace_call: -> { :first },
                   first_namespace_call: -> { :first },
                 })

    expect(Chamber.namespaces.to_a).to eql ['first']
  end
  # rubocop:enable Lint/DuplicatedKey

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

  it 'still raises an error if you try to send a message which the settings hash ' \
     'does not understand' do

    expect { Chamber.env.i_do_not_know }.to raise_error NoMethodError
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

    expect(Chamber.test.my_setting).to                eql 'my_value'
    expect(Chamber.test.my_other_setting).to          eql 'my_other_value'
    expect(Chamber.test.another_level.setting_one).to be  3
  end

  it 'loads YAML files from the "settings" directory under the base directory if ' \
     'any exist' do

    expect(Chamber.sub_settings.my_sub_setting).to eql 'my_sub_setting_value'
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

  # rubocop:disable Lint/DuplicatedKey
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
  # rubocop:enable Lint/DuplicatedKey

  it 'can notify properly whether it responds to messages if the underlying ' \
     'settings does' do

    expect(Chamber.respond_to?(:sub_settings)).to be_a TrueClass
  end

  it 'can explicitly specify files without specifying a basepath' do
    Chamber.load files: ['/tmp/chamber/settings.yml']

    expect(Chamber.filenames).to  eql ['/tmp/chamber/settings.yml']
    expect(Chamber.to_hash).to    include(
      'test' => include(
        'my_setting' => 'my_value',
        'my_ftp_url' => 'ftp://username:password@127.0.0.1',
      ),
    )
  end

  it 'ignores the basepath if file patterns are explicitly passed in' do
    Chamber.load basepath: '/tmp/chamber',
                 files:    'settings.yml'

    expect(Chamber.filenames).to be_empty
  end

  it 'can render itself as a string even if it has not been loaded' do
    Chamber.load basepath: '/'

    expect(Chamber.to_s).to eql ''
  end

  it 'can determine settings even if it has not been loaded' do
    Chamber.load basepath: '/'

    expect(Chamber.to_hash).to eql({})
  end

  it 'can unencrpyt an already encrpyted value if it has access to the private key' do
    Chamber.load(files:          '/tmp/chamber/secure.yml',
                 decryption_key: './spec/spec_key')

    expect(Chamber.test.my_encrpyted_setting).to eql 'hello'
  end
end
