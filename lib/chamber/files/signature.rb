# frozen_string_literal: true

require 'pathname'

module Chamber
module Files
class  Signature
  SIGNATURE_HEADER = '-----BEGIN CHAMBER SIGNATURE-----'
  SIGNATURE_FOOTER = '-----END CHAMBER SIGNATURE-----'

  attr_accessor :settings_content,
                :settings_filename

  attr_reader   :signature_key

  def initialize(settings_filename, settings_content, signature_key)
    self.signature_key     = signature_key
    self.settings_content  = settings_content
    self.settings_filename = Pathname.new(settings_filename)
  end

  def signature_key=(keyish)
    @signature_key ||= if keyish.is_a?(OpenSSL::PKey::RSA)
                         keyish
                       elsif ::File.readable?(::File.expand_path(keyish))
                         file_contents = ::File.read(::File.expand_path(keyish))
                         OpenSSL::PKey::RSA.new(file_contents)
                       else
                         OpenSSL::PKey::RSA.new(keyish)
                       end
  end

  def write
    signature_filename.write(<<-HEREDOC, 0, mode: 'w+')
Signed By: #{`git config --get 'user.name'`.chomp}
Signed At: #{Time.now.utc.iso8601}

#{SIGNATURE_HEADER}
#{encoded_signature}
#{SIGNATURE_FOOTER}
    HEREDOC
  end

  private

  def encoded_signature
    @encoded_signature ||= Base64.strict_encode64(raw_signature)
  end

  def raw_signature
    @raw_signature ||= signature_key.
                         sign(OpenSSL::Digest::SHA512.new, settings_content)
  end

  def signature_filename
    @signature_filename ||= settings_filename.
                              sub('.yml', '.sig').
                              sub('.erb', '')
  end
end
end
end
