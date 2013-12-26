require 'rspectacular'
require 'chamber'

File.open('/tmp/settings.yml', 'w+') do |file|
  file.puts <<-HEREDOC
test:
  my_setting: my_value
  HEREDOC
end

describe Chamber do
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
                   and_return 'settings.yml'

    Chamber.load(:basepath => '/tmp')

    expect(File).to have_received(:read).
                    with('/tmp/settings.yml')
  end

  it 'can access settings through a hash-like syntax' do
    expect(Chamber[:test][:my_setting]).to eql 'my_value'
  end
end
