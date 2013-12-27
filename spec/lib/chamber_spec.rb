require 'rspectacular'
require 'chamber'

File.open('/tmp/settings.yml', 'w+') do |file|
  file.puts <<-HEREDOC
test:
  my_setting: my_value
  my_dynamic_setting: <%= 1 + 1 %>
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

File.open('/tmp/settings-blue.yml', 'w+') do |file|
  file.puts <<-HEREDOC
other:
  everything: works
  HEREDOC
end

class CustomSettings < Chamber
  def my_namespace
    'blue'
  end

  def non_existant_namespace
    'unknown'
  end
end

describe Chamber, :singletons => [Chamber, CustomSettings] do
  before(:each) { Chamber.load(:basepath => '/tmp') }

  it 'knows how to load itself with a path string' do
    Chamber.load(:basepath => '/tmp')

    expect(Chamber.basepath.to_s).to eql '/tmp'
  end

  it 'knows how to load itself with a path object' do
    Chamber.load(:basepath => Pathname.new('/tmp'))

    expect(Chamber.basepath.to_s).to eql '/tmp'
  end

  it 'loads settings from a settings.yml file' do
    allow(File).to receive(:read).
                   and_return 'file: "settings.yml"'

    Chamber.load(:basepath => '/tmp')

    expect(File).to have_received(:read).
                    with('/tmp/settings.yml')
  end

  it 'processes settings files through ERB before YAML' do
    expect(Chamber[:test][:my_dynamic_setting]).to eql 2
  end

  it 'can access settings through a hash-like syntax' do
    expect(Chamber[:test][:my_setting]).to eql 'my_value'
  end

  it 'can access the settings through method-based access' do
    expect(Chamber.instance.test.my_setting).to eql 'my_value'
  end

  it 'can access the instance via "env"' do
    expect(Chamber.instance.test.my_setting).to eql 'my_value'
  end

  it 'prefers values stored in environment variables over those in the YAML files' do
    ENV['TEST_MY_SETTING'] = 'some_other_value'
    ENV['TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'] = 'something'

    Chamber.load(:basepath => '/tmp')
    expect(Chamber.instance.test.my_setting).to eql 'some_other_value'
    expect(Chamber.instance.test.another_level.level_three.an_array).to eql 'something'
    expect(Chamber.instance.test.my_dynamic_setting).to eql 2

    ENV.delete 'TEST_MY_SETTING'
    ENV.delete 'TEST_ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY'
  end

  it 'can load files based on the namespace passed in' do
    CustomSettings.namespaces :my_namespace
    CustomSettings.load(:basepath => '/tmp')

    expect(CustomSettings.instance.other.everything).to eql 'works'
    expect(CustomSettings.instance.test.my_dynamic_setting).to eql 2
  end

  it 'loads multiple namespaces if it is called twice' do
    Chamber.namespaces :first_namespace_call
    Chamber.namespaces :second_namespace_call

    expect(Chamber.instance.namespaces).to eql [:first_namespace_call, :second_namespace_call]
  end

  it 'does not load the same namespace twice' do
    Chamber.namespaces :first_namespace_call
    Chamber.namespaces :first_namespace_call

    expect(Chamber.instance.namespaces).to eql [:first_namespace_call]
  end

  it 'clears all settings each time the settings are loaded' do
    allow(Chamber.instance.settings).to receive(:clear)

    Chamber.load(:basepath => '/tmp')

    expect(Chamber.instance.settings).to  have_received(:clear).
                                          once
  end

  it 'still raises an error if you try to send a message which the settings hash does not understand' do
    expect{ Chamber.instance.i_do_not_know }.to raise_error NoMethodError
  end

  it 'does not raise an exception if a namespaced file does not exist' do
    CustomSettings.namespaces :non_existant_namespace

    expect { CustomSettings.load(:basepath => '/tmp') }.not_to raise_error
  end
end
