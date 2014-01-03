require 'pathname'
require 'yaml'

class   Chamber
class   File < Pathname
  def initialize(options = {})
    self.namespaces = options.fetch(:namespaces)

    super options.fetch(:path)
  end

  def to_settings
    @data ||= Settings.new(settings:    file_contents_hash,
                           namespaces:  namespaces)
  end

  protected

  attr_accessor :namespaces

  private

  def file_contents_hash
    file_contents = self.read
    erb_result    = ERB.new(file_contents).result

    YAML.load(erb_result)
  rescue Errno::ENOENT
    {}
  end
end
end
