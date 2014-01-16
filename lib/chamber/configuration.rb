require 'chamber/context_resolver'

module  Chamber
class   Configuration
  attr_accessor :basepath,
                :decryption_key,
                :encryption_key,
                :files,
                :namespaces

  def initialize(options = {})
    options             = ContextResolver.resolve(options)

    self.basepath       = options[:basepath]
    self.namespaces     = options[:namespaces]
    self.decryption_key = options[:decryption_key]
    self.encryption_key = options[:encryption_key]
    self.files          = options[:files]
  end

  def to_hash
    {
      basepath:       self.basepath,
      decryption_key: self.decryption_key,
      encryption_key: self.encryption_key,
      files:          self.files,
      namespaces:     self.namespaces,
    }
  end
end
end
