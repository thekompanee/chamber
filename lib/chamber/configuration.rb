module  Chamber
class   Configuration
  attr_accessor :basepath,
                :decryption_key,
                :files,
                :namespaces

  def initialize(options = {})
    self.basepath       = options[:basepath]        || ''
    self.namespaces     = options[:namespaces]      || []
    self.decryption_key = options[:decryption_key]
    self.files          = options[:files]           || [
                        self.basepath + 'credentials*.yml',
                        self.basepath + 'settings*.yml',
                        self.basepath + 'settings' ]
  end

  def to_hash
    {
      basepath:       self.basepath,
      decryption_key: self.decryption_key,
      files:          self.files,
      namespaces:     self.namespaces,
    }
  end

  def basepath=(pathlike)
    @basepath = pathlike == '' ? '' : Pathname.new(::File.expand_path(pathlike))
  end
end
end
