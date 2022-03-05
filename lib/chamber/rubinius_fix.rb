# frozen_string_literal: true

require 'pathname'

unless Pathname.instance_methods.include?(:write)
  class Pathname
    def write(*args)
      IO.write @path, *args # rubocop:disable Security/IoMethods
    end
  end
end
