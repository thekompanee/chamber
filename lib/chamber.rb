module Chamber

  class << self
    attr_accessor :basepath
  end

  def self.load(options = {})
    self.basepath = options.fetch(:basepath)
  end

  private

  def self.basepath=(pathlike)
    @basepath = Pathname.new(File.expand_path(pathlike))
  end
end
