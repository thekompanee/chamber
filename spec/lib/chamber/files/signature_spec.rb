# frozen_string_literal: true

require 'rspectacular'
require 'securerandom'
require 'chamber/files/signature'

module   Chamber
module   Files
describe Signature do
  it 'can write a signature file', :time_mock do
    seed = SecureRandom.uuid
    file = Signature.new("/tmp/settings-#{seed}.yml",
                         'my settings content',
                         'spec/spec_key',
                         'Suzy Q Robinson')

    file.write

    signature_contents = ::File.read("/tmp/settings-#{seed}.sig")

    expect(signature_contents).to eql(<<-HEREDOC)
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
HxXUpr8+UhpdOSgqM778KLZTHYjYnTnOfPzr5SiYCtFOgckdM2IxlmrYvYSP2a9Xw0gptXJLE1CxpT19YefhTzL8WzJF6ut6ByVkDeJKv+1UXqQcvtFhOsponN9vsvZALJoH36AL34GXmUiNXpjoqZuw5BFhq/j321ddy3TD7YTfzF+9vYQTGfB6coMpQAn1x7Vctg7PZeNHsG443EIifbIP4x/ql05sxvyg8i3L7LJ4cxZ1y5EVdOYjLxHvZZ19jq2/ELHVh1gKZ5AR/sHx9r/5Lq12u3qeBRIdsxNfFax+dYA2/7zdos/vxqLZe2wrQKK010kose8pTc8Rq+p7/Q==
-----END CHAMBER SIGNATURE-----
    HEREDOC
  end

  it 'can write an ERB signature file', :time_mock do
    seed = SecureRandom.uuid
    file = Signature.new("/tmp/settings-#{seed}.yml.erb",
                         'my settings content',
                         'spec/spec_key',
                         'Suzy Q Robinson')

    file.write

    signature_contents = ::File.read("/tmp/settings-#{seed}.sig")

    expect(signature_contents).to eql(<<-HEREDOC)
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
HxXUpr8+UhpdOSgqM778KLZTHYjYnTnOfPzr5SiYCtFOgckdM2IxlmrYvYSP2a9Xw0gptXJLE1CxpT19YefhTzL8WzJF6ut6ByVkDeJKv+1UXqQcvtFhOsponN9vsvZALJoH36AL34GXmUiNXpjoqZuw5BFhq/j321ddy3TD7YTfzF+9vYQTGfB6coMpQAn1x7Vctg7PZeNHsG443EIifbIP4x/ql05sxvyg8i3L7LJ4cxZ1y5EVdOYjLxHvZZ19jq2/ELHVh1gKZ5AR/sHx9r/5Lq12u3qeBRIdsxNfFax+dYA2/7zdos/vxqLZe2wrQKK010kose8pTc8Rq+p7/Q==
-----END CHAMBER SIGNATURE-----
    HEREDOC
  end

  it 'can verify a signature file', :time_mock do
    seed               = SecureRandom.uuid
    settings_filename  = "/tmp/settings-#{seed}.yml"
    signature_filename = "/tmp/settings-#{seed}.sig"

    ::File.write(signature_filename, <<-HEREDOC, mode: 'w+')
Signed By: Suzy Q Robinson
Signed At: 2012-07-26T18:00:00Z

-----BEGIN CHAMBER SIGNATURE-----
HxXUpr8+UhpdOSgqM778KLZTHYjYnTnOfPzr5SiYCtFOgckdM2IxlmrYvYSP2a9Xw0gptXJLE1CxpT19YefhTzL8WzJF6ut6ByVkDeJKv+1UXqQcvtFhOsponN9vsvZALJoH36AL34GXmUiNXpjoqZuw5BFhq/j321ddy3TD7YTfzF+9vYQTGfB6coMpQAn1x7Vctg7PZeNHsG443EIifbIP4x/ql05sxvyg8i3L7LJ4cxZ1y5EVdOYjLxHvZZ19jq2/ELHVh1gKZ5AR/sHx9r/5Lq12u3qeBRIdsxNfFax+dYA2/7zdos/vxqLZe2wrQKK010kose8pTc8Rq+p7/Q==
-----END CHAMBER SIGNATURE-----
    HEREDOC

    file = Signature.new(settings_filename,
                         'my settings content',
                         'spec/spec_key.pub',
                         'Suzy Q Robinson')

    expect(file.verify).to be true
  end
end
end
end
