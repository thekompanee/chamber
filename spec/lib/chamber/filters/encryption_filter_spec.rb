require 'rspectacular'
require 'chamber/filters/encryption_filter'

module    Chamber
module    Filters
describe  EncryptionFilter do
  it 'will attempt to encrypt values which are marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   _secure_my_secure_setting: 'hello' },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt values which are not marked as "secure"' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   my_secure_setting: 'hello' },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings.my_secure_setting).to eql 'hello'
  end

  it 'will not attempt to encrypt values even if they are prefixed with "secure"' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   secure_setting: 'hello' },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings.secure_setting).to eql 'hello'
  end

  it 'will attempt to encrypt values if they are not properly encoded' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   _secure_my_secure_setting: 'fNI5\jwlBn' },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to match EncryptionFilter::BASE64_STRING_PATTERN
  end

  it 'will not attempt to encrypt values if it guesses that they are already encrpyted' do
    filtered_settings = EncryptionFilter.execute(data:           {
                                                   _secure_my_secure_setting: 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7PzprewBX8CXYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr054gGxeqZexbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntidMY9Lx4pqSkhYXwQnI48d2Dh44qfaS9w2OrehSkpdFRnuxQeOpCKO/bleB0J88WGkytCohyHCRIpbaEjEC3UD52pnqMeu/ClNm+PBgE6Ci94pu5UUnZuIE/y+P4A3wgD6G/u8hgvAW51JwVryg/im1rayGAwWYNgupQ/5LDmjffwx7Q3fyMH2uF3CDIKRIC6U+mnM5SRMO4Dzysw==' },
                                                 encryption_key: './spec/spec_key.pub')

    expect(filtered_settings._secure_my_secure_setting).to eql 'fNI5wlBniNhEU4396pmhWwx+A09bRAMJOUASuP7PzprewBX8CXYqL+v/uXOJpIRCLDjwe8quuC+j9iLcPU7HBRMr054gGxeqZexbLevXcPk7SrMis3qeEKmnAuarQGXe7ZAntidMY9Lx4pqSkhYXwQnI48d2Dh44qfaS9w2OrehSkpdFRnuxQeOpCKO/bleB0J88WGkytCohyHCRIpbaEjEC3UD52pnqMeu/ClNm+PBgE6Ci94pu5UUnZuIE/y+P4A3wgD6G/u8hgvAW51JwVryg/im1rayGAwWYNgupQ/5LDmjffwx7Q3fyMH2uF3CDIKRIC6U+mnM5SRMO4Dzysw=='
  end
end
end
end
