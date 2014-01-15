require 'tempfile'

module  Chamber
module  Commands
module  Comparable

  def initialize(options = {})
    super

    self.keys_only = options[:keys_only]
  end

  def call
    system("git diff --no-index #{first_settings_file} #{second_settings_file}")
  end

  protected

  attr_accessor :keys_only

  def first_settings_file
    create_comparable_settings_file 'first',  first_settings_data
  end

  def second_settings_file
    create_comparable_settings_file 'second', second_settings_data
  end

  def create_comparable_settings_file(name, config)
    Tempfile.open(name) do |file|
      file.write config
      file.to_path
    end
  end
end
end
end
