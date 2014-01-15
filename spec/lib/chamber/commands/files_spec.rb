require 'rspectacular'
require 'chamber/commands/files'

module    Chamber
module    Commands
describe  Files do
  let(:rootpath) { ::File.expand_path('./spec/fixtures') }
  let(:options)  { {  basepath: rootpath,
                      rootpath: rootpath } }

  it 'can return values formatted as environment variables' do
    files = Files.call(options)

    expect(files.size).to   eql     1
    expect(files.first).to  include 'spec/fixtures/settings.yml'
  end
end
end
end
