require 'chamber/namespace_set'
require 'chamber/file'
require 'chamber/settings'

###
# Internal: Represents a set of settings files that should be considered for
# processing. Whether they actually *are* processed depends on their extension
# (only *.yml files are processed unless explicitly specified), and whether
# their namespace matches one of the namespaces passed to the FileSet (text
# after a dash '-' but before the extension is considered the namespace for the
# file).
#
# When converted to settings, files are always processed in the order of least
# specific to most specific.  So if there are two files:
#
# * /tmp/settings.yml
# * /tmp/settings-blue.yml
#
# Then '/tmp/settings.yml' will be processed first and '/tmp/settings-blue.yml'
# will be processed second (assuming a namespace with the value 'blue' was
# passed in).
#
# If there are multiple namespaces, they will be process in the order that they
# appear in the passed in hash.  So assuming two files:
#
# * /tmp/settings-blue.yml
# * /tmp/settings-green.yml
#
# Then:
#
# ```ruby
# FileSet.new files:      '/tmp/settings*.yml',
#             namespaces: ['blue', 'green']
# ```
#
# will process in this order:
#
# * /tmp/settings-blue.yml
# * /tmp/settings-green.yml
#
# Whereas:
#
# ```ruby
# FileSet.new files:      '/tmp/settings*.yml',
#             namespaces: ['green', 'blue']
# ```
#
# will process in this order:
#
# * /tmp/settings-green.yml
# * /tmp/settings-blue.yml
#
# Examples:
#
#   ###
#   # Assuming the following files exist:
#   #
#   # /tmp/settings.yml
#   # /tmp/settings-blue.yml
#   # /tmp/settings-green.yml
#   # /tmp/settings/another.yml
#   # /tmp/settings/another.json
#   # /tmp/settings/yet_another-blue.yml
#   # /tmp/settings/yet_another-green.yml
#   #
#
#   ###
#   # This will *consider* all files listed but will only process 'settings.yml'
#   # and 'another.yml'
#   #
#   FileSet.new files: ['/tmp/settings.yml',
#                       '/tmp/settings']
#
#   ###
#   # This will all files in the 'settings' directory but will only process
#   # 'another.yml' and 'yet_another-blue.yml'
#   #
#   FileSet.new(files:      '/tmp/settings',
#               namespaces: {
#                 favorite_color: 'blue' } )
#
#   ###
#   # Passed in namespaces do not have to be hashes. Hash keys are used only for
#   # human readability.
#   #
#   # This results in the same outcome as the example above.
#   #
#   FileSet.new(files:      '/tmp/settings',
#               namespaces: ['blue'])
#
#   ###
#   # This will process all files listed:
#   #
#   FileSet.new(files:      [
#                             '/tmp/settings*.yml',
#                             '/tmp/settings',
#                           ],
#               namespaces: %w{blue green})
#
#   ###
#   # This is the only way to explicitly specify files which do not end in
#   # a 'yml' extension.
#   #
#   # This is the only example thus far which will process
#   # '/tmp/settings/another.json'
#   #
#   FileSet.new(files:      '/tmp/settings/*.json',
#               namespaces: %w{blue green})
#
class   Chamber
class   FileSet

  def initialize(options = {})
    self.namespaces = options.fetch(:namespaces, {})
    self.paths      = options.fetch(:files)
  end

  ###
  # Internal: Returns an Array of the ordered list of files that was processed
  # by Chamber in order to get the resulting settings values.  This is useful
  # for debugging if a given settings value isn't quite what you anticipated it
  # should be.
  #
  # Returns an Array of file path strings
  #
  def filenames
    @filenames ||= files.map(&:to_s)
  end

  ###
  # Internal: Converts the FileSet into a Settings object which represents all
  # the settings specified in all of the files in the FileSet.
  #
  # This can be used in one of two ways. You may either specify a block which
  # will be passed each file's settings as they are converted, or you can choose
  # not to pass a block, in which case it will pass back a single completed
  # Settings object to the caller.
  #
  # The reason the block version is used in Chamber.settings is because we want
  # to be able to load each settings file as it's processed so that we can use
  # those already-processed settings in subsequently processed settings files.
  #
  # Examples:
  #
  #   ###
  #   # Specifying a Block
  #   #
  #   file_set = FileSet.new files: [ '/path/to/my/settings.yml' ]
  #
  #   file_set.to_settings do |settings|
  #     # do stuff with each settings
  #   end
  #
  #
  #   ###
  #   # No Block Specified
  #   #
  #   file_set = FileSet.new files: [ '/path/to/my/settings.yml' ]
  #   file_set.to_settings
  #
  #   # => <Chamber::Settings>
  #
  def to_settings
    clean_settings = Settings.new(:namespaces => namespaces)

    files.each_with_object(clean_settings) do |file, settings|
      if block_given?
        yield file.to_settings
      else
        settings.merge!(file.to_settings)
      end
    end
  end

  protected

  attr_reader   :namespaces,
                :paths

  ###
  # Internal: Allows the paths for the FileSet to be set. It can either be an
  # object that responds to `#each` like an Array or one that doesn't. In which
  # case it will be considered a single path.
  #
  # All paths will be converted to Pathnames.
  #
  def paths=(raw_paths)
    raw_paths = [raw_paths] unless raw_paths.respond_to? :each

    @paths = raw_paths.map { |path| Pathname.new(path) }
  end

  ###
  # Internal: Allows the namespaces for the FileSet to be set.  An Array or Hash
  # can be passed; in both cases it will be converted to a NamespaceSet.
  #
  def namespaces=(raw_namespaces)
    @namespaces = NamespaceSet.new(raw_namespaces)
  end

  ###
  # Internal: The set of files which are considered to be relevant, but with any
  # duplicates removed.
  #
  def files
    @files ||= -> do
      sorted_relevant_files = []

      file_globs.each do |glob|
        current_glob_files  = Pathname.glob(glob)
        relevant_glob_files = relevant_files & current_glob_files

        relevant_glob_files.map! { |file| File.new( path:        file,
                                                    namespaces:  namespaces) }

        sorted_relevant_files += relevant_glob_files
      end

      sorted_relevant_files.uniq
    end.call
  end

  private

  def all_files
    @all_files ||= Pathname.glob(file_globs)
  end

  def non_namespaced_files
    @non_namespaced_files ||= all_files - namespaced_files
  end

  def relevant_files
    @relevant_files ||= non_namespaced_files + relevant_namespaced_files
  end

  def file_globs
    @file_globs ||= paths.map do |path|
                      if path.directory?
                        path + '*.yml'
                      else
                        path
                      end
                    end
  end

  def namespaced_files
    @namespaced_files ||= all_files.select do |file|
                            file.fnmatch? '*-*'
                          end
  end

  def relevant_namespaced_files
    file_holder = []

    namespaces.each do |namespace|
      file_holder << namespaced_files.select do |file|
                       file.fnmatch? "*-#{namespace}.???"
                     end
    end

    file_holder.flatten
  end
end
end
