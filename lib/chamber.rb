require 'singleton'
require 'forwardable'

module Chamber
  include Singleton

  def_delgators :instance,  :load,
                            :basepath

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
