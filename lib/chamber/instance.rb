require 'chamber/configuration'
require 'chamber/file_set'

module  Chamber
class   Instance
  attr_accessor :configuration,
                :files

  def initialize(options = {})
    self.configuration = Configuration.new  options
    self.files         = FileSet.new        configuration.to_hash
  end

  def settings
    @settings ||= files.to_settings { |settings| @settings = settings }
  end
end
end
