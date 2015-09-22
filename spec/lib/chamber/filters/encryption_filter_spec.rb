require 'rspectacular'
require 'chamber/filters/encryption_filter'

module    Chamber
module    Filters
describe  EncryptionFilter do
  it 'will attempt to encrypt values which are marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(
      data:           {
        _secure_my_secure_setting: 'hello' },
      encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt values which are not marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(
      data:           {
        my_secure_setting: 'hello' },
      encryption_key: './spec/spec_key.pub')

    expect(filtered_settings.my_secure_setting).to eql 'hello'
  end

  it 'will not attempt to encrypt values even if they are prefixed with "secure"' do
    filtered_settings = EncryptionFilter.execute(
      data:           {
        secure_setting: 'hello' },
      encryption_key: './spec/spec_key.pub')

    expect(filtered_settings.secure_setting).to eql 'hello'
  end

  it 'will attempt to encrypt values if they are not properly encoded' do
    filtered_settings = EncryptionFilter.execute(
      data:           {
        _secure_my_secure_setting: 'fNI5\jwlBn' },
      encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will attempt to encrypt values if they are numbers' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   _secure_my_secure_setting: 12_345 },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt values if it guesses that they are already encrypted' do
    filtered_settings = EncryptionFilter.execute(
      data:           {
        _secure_my_secure_setting: 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7PzprewBX8C' \
                                   'XYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr054gGxeqZe' \
                                   'xbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntidMY9Lx4pqSkhY' \
                                   'XwQnI48d2Dh44qfaS9w2OrehSkpdFRnuxQeOpCKO/bleB0J88' \
                                   'WGkytCohyHCRIpbaEjEC3UD52pnqMeu/ClNm+PBgE6Ci94pu5' \
                                   'UUnZuIE/y+P4A3wgD6G/u8hgvAW51JwVryg/im1rayGAwWYNg' \
                                   'upQ/5LDmjffwx7Q3fyMH2uF3CDIKRIC6U+mnM5SRMO4Dzysw==',
      },
      encryption_key: './spec/spec_key.pub')

    my_secure_setting = filtered_settings._secure_my_secure_setting

    expect(my_secure_setting).to eql 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7Pzprew' \
                                     'BX8CXYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr05' \
                                     '4gGxeqZexbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntid' \
                                     'MY9Lx4pqSkhYXwQnI48d2Dh44qfaS9w2OrehSkpdFRnux' \
                                     'QeOpCKO/bleB0J88WGkytCohyHCRIpbaEjEC3UD52pnqM' \
                                     'eu/ClNm+PBgE6Ci94pu5UUnZuIE/y+P4A3wgD6G/u8hgv' \
                                     'AW51JwVryg/im1rayGAwWYNgupQ/5LDmjffwx7Q3fyMH2' \
                                     'uF3CDIKRIC6U+mnM5SRMO4Dzysw=='
  end

  it "will encrypt strings of 127 chars effective length" do
    # Prove there is no gap in length between the small and long encryption types that could
    # cause an OpenSSL exception because assymetric encryption can only be done with small
    # data.
    filtered_settings = EncryptionFilter.execute(
        data:           {
            _secure_my_secure_setting: "A"*119 },
        encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::BASE64_STRING_PATTERN

    filtered_settings = EncryptionFilter.execute(
        data:           {
            _secure_my_secure_setting: "A"*120 }, # one char longer
        encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::LARGEDATA_STRING_PATTERN

  end

  it "will encrypt and decrypt strings larger than 128 chars" do
    filtered_settings = EncryptionFilter.execute(
        data:           {
            _secure_my_secure_setting: "long"*100 },
        encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match \
      EncryptionFilter::LARGEDATA_STRING_PATTERN

  end
end
end
end
