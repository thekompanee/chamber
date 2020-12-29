# frozen_string_literal: true

require 'shellwords'
require 'chamber/instance'

module  Chamber
module  Commands
module  Securable
  def initialize(only_sensitive: nil, **args)
    super(**args)

    ignored_settings_options        = args
                                        .merge(files: ignored_settings_filepaths)
                                        .reject { |k, _v| k == 'basepath' }
    self.ignored_settings_instance  = Chamber::Instance.new(**ignored_settings_options)
    self.current_settings_instance  = Chamber::Instance.new(**args)
    self.only_sensitive             = only_sensitive
  end

  protected

  attr_accessor :only_sensitive,
                :ignored_settings_instance,
                :current_settings_instance

  def securable_environment_variables
    if only_sensitive
      securable_settings.to_environment
    else
      current_settings.to_environment
    end
  end

  def insecure_environment_variables
    securable_settings.insecure.to_environment
  end

  def securable_settings
    ignored_settings.merge(current_settings.securable)
  end

  def current_settings
    current_settings_instance.settings
  end

  def ignored_settings
    ignored_settings_instance.settings
  end

  def ignored_settings_filepaths
    shell_escaped_chamber_filenames = chamber.filenames.map do |filename|
      Shellwords.escape(filename)
    end

    `
      git ls-files --other --ignored --exclude-per-directory=.gitignore |
      sed -e "s|^|#{Shellwords.escape(rootpath.to_s)}/|" |
      grep --colour=never -E '#{shell_escaped_chamber_filenames.join('|')}'
    `.split("\n")
  end
end
end
end
