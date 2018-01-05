# frozen_string_literal: true

require 'chamber/context_resolver'

module  Chamber
class   Configuration
  attr_accessor :basepath,
                :decryption_keys,
                :encryption_keys,
                :files,
                :namespaces

  def initialize(options = {})
    options              = ContextResolver.resolve(options)

    self.basepath        = options.fetch(:basepath)
    self.namespaces      = options.fetch(:namespaces)
    self.decryption_keys = options.fetch(:decryption_keys)
    self.encryption_keys = options.fetch(:encryption_keys)
    self.files           = options.fetch(:files)
  end

  def to_hash
    {
      basepath:        basepath,
      decryption_keys: decryption_keys,
      encryption_keys: encryption_keys,
      files:           files,
      namespaces:      namespaces,
    }
  end
end
end
