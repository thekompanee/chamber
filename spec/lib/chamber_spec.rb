require 'rspectacular'
require 'chamber'

describe Chamber do
  it 'knows how to load itself with a path string' do
    Chamber.load(:basepath => '/tmp')

    expect(Chamber.basepath.to_s).to eql '/tmp'
  end

  it 'knows how to load itself with a path object' do
    Chamber.load(:basepath => Pathname.new('/tmp'))

    expect(Chamber.basepath.to_s).to eql '/tmp'
  end
end
