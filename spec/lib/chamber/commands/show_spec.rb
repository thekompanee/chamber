require 'rspectacular'
require 'chamber/commands/show'

# rubocop:disable Metrics/LineLength
module    Chamber
module    Commands
describe  Show do
  let(:rootpath) { ::File.expand_path('./spec/fixtures') }
  let(:options) do
    {
      basepath:       rootpath,
      rootpath:       rootpath,
      namespaces:     'test',
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
MY_SECURE_SETTINGS="M3yI2fIHsfD+zznsvO3FB/ryCwvvdQQ9ZXPQlTIR6Y9vtzNFAeRAxZpSyYUdOpeMDkWQSo5ZVLseM20iTh1YpNCjzd7D0bT4O9aBskYBE92b4ioYPAPSZ3NcvA1pGa6A/hWGo3iJZK1t96mGrfxy2mSFFqGHQbj4ix6D7PpCfVkjuUMp3NG3XjgGhmynK88XENWXBQfgxdfwylZZSQTm058BubkuM5MXgf4WGL3qWo+wWk9AOwjohAGq3UAf5Q341g/OlPGbCV3rBPTnlm866N8aAsHtppg5HwbknaySpLMPcv0KhUGC/bEPgbm3tuG7JZKsoqvDmWr/I+LjVi/LKg=="
MY_SETTING="my_value"
HEREDOC
    )
  end

  it 'can return values filtered by whether or not they are secure' do
    expect(Show.call(options.merge(as_env: true, only_secure: true))).to eql(
<<-HEREDOC.chomp
MY_SECURE_SETTINGS="M3yI2fIHsfD+zznsvO3FB/ryCwvvdQQ9ZXPQlTIR6Y9vtzNFAeRAxZpSyYUdOpeMDkWQSo5ZVLseM20iTh1YpNCjzd7D0bT4O9aBskYBE92b4ioYPAPSZ3NcvA1pGa6A/hWGo3iJZK1t96mGrfxy2mSFFqGHQbj4ix6D7PpCfVkjuUMp3NG3XjgGhmynK88XENWXBQfgxdfwylZZSQTm058BubkuM5MXgf4WGL3qWo+wWk9AOwjohAGq3UAf5Q341g/OlPGbCV3rBPTnlm866N8aAsHtppg5HwbknaySpLMPcv0KhUGC/bEPgbm3tuG7JZKsoqvDmWr/I+LjVi/LKg=="
HEREDOC
    )
  end

  it 'can return values formatted as a hash' do
    expect(Show.call(options)).to eql(
<<-HEREDOC.chomp
{"my_setting"=>"my_value",
 "my_secure_settings"=>
  "M3yI2fIHsfD+zznsvO3FB/ryCwvvdQQ9ZXPQlTIR6Y9vtzNFAeRAxZpSyYUdOpeMDkWQSo5ZVLseM20iTh1YpNCjzd7D0bT4O9aBskYBE92b4ioYPAPSZ3NcvA1pGa6A/hWGo3iJZK1t96mGrfxy2mSFFqGHQbj4ix6D7PpCfVkjuUMp3NG3XjgGhmynK88XENWXBQfgxdfwylZZSQTm058BubkuM5MXgf4WGL3qWo+wWk9AOwjohAGq3UAf5Q341g/OlPGbCV3rBPTnlm866N8aAsHtppg5HwbknaySpLMPcv0KhUGC/bEPgbm3tuG7JZKsoqvDmWr/I+LjVi/LKg==",
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
# rubocop:enable Metrics/LineLength
