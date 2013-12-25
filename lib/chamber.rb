require 'singleton'
require 'forwardable'

class Chamber
  include Singleton

  class << self
    extend Forwardable

    def_delegators :instance, :load,
                              :basepath
  end

  attr_accessor :basepath

  def load(options)
    self.basepath = options.fetch(:basepath)

    load_file(self.basepath + 'settings.yml')
  end

  private

  def basepath=(pathlike)
    @basepath = Pathname.new(File.expand_path(pathlike))
  end

  def load_file(file_path)
    File.read file_path.to_s
  end
end
