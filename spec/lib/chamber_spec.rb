require 'spec_helper'

class MySettings
  extend Chamber
end

describe Chamber do
  it 'adds a source method to extending classes' do
    expect(MySettings).to respond_to :source
  end
end
