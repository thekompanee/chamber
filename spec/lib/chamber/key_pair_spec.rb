# frozen_string_literal: true

require 'rspectacular'
require 'chamber/key_pair'

module   Chamber
describe KeyPair do
  it 'can generate a private key' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.unencrypted_private_key_pem)
      .to match(
            /
              -----BEGIN\sRSA\sPRIVATE\sKEY-----\n # Private Key Header
              .*                                   # Any Key Contents
              -----END\sRSA\sPRIVATE\sKEY-----\n   # Private Key Footer
            /xm,
          )
  end

  it 'can generate a encrypted private key' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.encrypted_private_key_pem)
      .to match(
            /
              -----BEGIN\sRSA\sPRIVATE\sKEY-----\n # Private Key Header
              Proc-Type:\s4,ENCRYPTED\n            # Encryption Header
              .*                                   # Any Key Contents
              -----END\sRSA\sPRIVATE\sKEY-----\n   # Private Key Footer
            /xm,
          )
  end

  it 'can generate a public key' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.public_key_pem)
      .to match(
            /
              -----BEGIN\sPUBLIC\sKEY----- # Public Key Header
              .*                           # Any Key Contents
              -----END\sPUBLIC\sKEY-----\n # Public Key Footer
            /xm,
          )
  end

  it 'can construct a default private key filepath' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.unencrypted_private_key_filepath.to_s).to eql './tmp/.chamber.pem'
  end

  it 'can construct a default encrypted private key filepath' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.encrypted_private_key_filepath.to_s).to eql './tmp/.chamber.enc'
  end

  it 'can construct a default public key filepath' do
    key_pair = KeyPair.new(key_file_path: './tmp/')

    expect(key_pair.public_key_filepath.to_s).to eql './tmp/.chamber.pub.pem'
  end

  it 'can construct a namespaced private key filepath' do
    key_pair = KeyPair.new(namespace:     'mynamespace',
                           key_file_path: './tmp/')

    expect(key_pair.unencrypted_private_key_filepath.to_s).to eql './tmp/.chamber.mynamespace.pem'
  end

  it 'can construct a namespaced encrypted private key filepath' do
    key_pair = KeyPair.new(namespace:     'mynamespace',
                           key_file_path: './tmp/')

    expect(key_pair.encrypted_private_key_filepath.to_s).to eql './tmp/.chamber.mynamespace.enc'
  end

  it 'can construct a namespaced public key filepath' do
    key_pair = KeyPair.new(namespace:     'mynamespace',
                           key_file_path: './tmp/')

    expect(key_pair.public_key_filepath.to_s).to eql './tmp/.chamber.mynamespace.pub.pem'
  end

  it 'knows to remove special characters from the namespace before adding it to the file' do
    key_pair = KeyPair.new(namespace:     'my-name.space',
                           key_file_path: './tmp/')

    expect(key_pair.unencrypted_private_key_filepath.to_s).to eql './tmp/.chamber.mynamespace.pem'
  end
end
end
