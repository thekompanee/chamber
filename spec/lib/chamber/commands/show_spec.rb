require 'rspectacular'
require 'chamber/commands/show'

module    Chamber
module    Commands
describe  Show do
  let(:rootpath) { ::File.expand_path('./spec/fixtures') }
  let(:options) do
    {
      basepath:       rootpath,
      rootpath:       rootpath,
      namespaces:     'test',
      decryption_key: './spec/spec_key',
    }
  end

  it 'can return values formatted as environment variables' do
    expect(Show.call(options.merge(as_env: true))).to eql(
<<-HEREDOC.chomp
ANOTHER_LEVEL_LEVEL_THREE_A_SCALAR="hello"
ANOTHER_LEVEL_LEVEL_THREE_AN_ARRAY="["item 1", "item 2", "item 3"]"
ANOTHER_LEVEL_SETTING_ONE="1"
ANOTHER_LEVEL_SETTING_TWO="2"
MY_BOOLEAN="false"
MY_DYNAMIC_SETTING="2"
MY_SECURE_SETTINGS="my_secure_value"
MY_SETTING="my_value"
HEREDOC
    )
  end

  it 'can return values filtered by whether or not they are secure' do
    expect(Show.call(options.merge(as_env: true, only_sensitive: true))).to eql(
<<-HEREDOC.chomp
MY_SECURE_SETTINGS="my_secure_value"
HEREDOC
    )
  end

  it 'can return values formatted as a hash' do
    expect(Show.call(options)).to eql(
<<-HEREDOC.chomp
{"my_setting"=>"my_value",
 "my_secure_settings"=>"my_secure_value",
 "my_boolean"=>false,
 "my_dynamic_setting"=>2,
 "another_level"=>
  {"setting_one"=>1,
   "setting_two"=>2,
   "level_three"=>
    {"an_array"=>["item 1", "item 2", "item 3"],
     "a_scalar"=>"hello"}}}
HEREDOC
    )
  end
end
end
end
