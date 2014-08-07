require 'pathname'

unless Pathname.new('foo').respond_to? :write
  class Pathname
    def write(*args)
      IO.write @path, *args
    end
  end
end
