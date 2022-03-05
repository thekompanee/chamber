# frozen_string_literal: true

require 'base64'
require 'pathname'
require 'time'

module Chamber
module Files
class  Signature
  SIGNATURE_HEADER          = '-----BEGIN CHAMBER SIGNATURE-----'
  SIGNATURE_HEADER_PATTERN  = /-----BEGIN\sCHAMBER\sSIGNATURE-----/.freeze
  SIGNATURE_FOOTER          = '-----END CHAMBER SIGNATURE-----'
  SIGNATURE_FOOTER_PATTERN  = /-----END\sCHAMBER\sSIGNATURE-----/.freeze
  SIGNATURE_IN_FILE_PATTERN = /
                                #{SIGNATURE_HEADER_PATTERN}\n # Header
                                (.*)\n                        # Signature Body
                                #{SIGNATURE_FOOTER_PATTERN}   # Footer
                              /x.freeze

  attr_accessor :settings_content,
                :settings_filename,
                :signature_name

  attr_reader   :signature_key

  def initialize(settings_filename, settings_content, signature_key, signature_name)
    self.signature_key     = signature_key
    self.settings_content  = settings_content
    self.settings_filename = Pathname.new(settings_filename)
    self.signature_name    = signature_name
  end

  def signature_key=(keyish)
    @signature_key = if keyish.is_a?(OpenSSL::PKey::RSA)
                       keyish
                     elsif ::File.readable?(::File.expand_path(keyish))
                       file_contents = ::File.read(::File.expand_path(keyish))
                       OpenSSL::PKey::RSA.new(file_contents)
                     else
                       OpenSSL::PKey::RSA.new(keyish)
                     end
  end

  def write
    signature_filename.write(<<~HEREDOC, 0, mode: 'w+')
      Signed By: #{signature_name}
      Signed At: #{Time.now.utc.iso8601}

      #{SIGNATURE_HEADER}
      #{encoded_signature}
      #{SIGNATURE_FOOTER}
    HEREDOC
  end

  def verify
    signature_key.verify(digest, signature_content, settings_content)
  end

  private

  def encoded_signature
    @encoded_signature ||= Base64.strict_encode64(raw_signature)
  end

  def raw_signature
    @raw_signature ||= signature_key
                         .sign(digest, settings_content)
  end

  def signature_filename
    @signature_filename ||= settings_filename
                              .sub('.yml', '.sig')
                              .sub('.erb', '')
  end

  def encoded_signature_content
    @encoded_signature_content ||= signature_filename
                                     .read
                                     .match(SIGNATURE_IN_FILE_PATTERN) do |match|
      match[1]
    end
  end

  def signature_content
    @signature_content ||= Base64.strict_decode64(encoded_signature_content)
  end

  def digest
    @digest ||= OpenSSL::Digest.new('SHA512')
  end
end
end
end
