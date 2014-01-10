require 'chamber/file_set'

module  Chamber
class   Configuration
  attr_accessor :basepath,
                :decryption_key,
                :files

  def initialize(options = {})
    self.basepath       = options[:basepath] || ''
    self.decryption_key = options[:decryption_key]
    file_patterns       = options[:files] || [
                            self.basepath + 'credentials*.yml',
                            self.basepath + 'settings*.yml',
                            self.basepath + 'settings' ]
    self.files          = FileSet.new files:      file_patterns,
                                      namespaces: options.fetch(:namespaces, {})
  end

  def settings
    @settings ||= -> do
      @settings = Settings.new(decryption_key: self.decryption_key)

      files.to_settings do |parsed_settings|
        @settings = @settings.merge(parsed_settings)
      end

      @settings
    end.call
  end

  def to_s
    settings.to_s
  end

  def basepath=(pathlike)
    @basepath = pathlike == '' ? '' : Pathname.new(::File.expand_path(pathlike))
  end
end
end
