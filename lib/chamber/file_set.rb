require 'set'
require 'chamber/namespace_set'
require 'chamber/file'
require 'chamber/settings'

class   Chamber
class   FileSet
  include Enumerable

  def initialize(options = {})
    self.namespaces = options.fetch(:namespaces, {})
    self.paths      = options.fetch(:files)
  end

  def each
    files.each do |file|
      yield file
    end
  end

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

  attr_reader   :files,
                :namespaces

  attr_accessor :paths

  def namespaces=(raw_namespaces)
    @namespaces ||= NamespaceSet.new(raw_namespaces)
  end

  def files
    @files ||= Set.new relevant_files
  end

  private

  def all_files
    @all_files ||= Pathname.glob(file_globs)
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

  def relevant_files
    @relevant_files ||= -> do
      non_namespaced_files = all_files - namespaced_files
      relevant_files       = non_namespaced_files + relevant_namespaced_files

      relevant_files.map { |file| File.new( path:        file,
                                            namespaces:  namespaces) }
    end.call
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
