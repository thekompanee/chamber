require 'hashie/mash'
require 'chamber/system_environment'
require 'chamber/namespace_set'

class   Chamber
class   Settings

  attr_reader :namespaces

  def initialize(options = {})
    self.namespaces = options.fetch(:namespaces,  NamespaceSet.new)
    self.data       = options.fetch(:settings,    Hashie::Mash.new)
  end

  def to_environment
    SystemEnvironment.extract_from(data)
  end

  def merge!(other)
    self.data       = data.merge(other.to_hash)
    self.namespaces = (namespaces + other.namespaces) if other.respond_to? :namespaces
  end

  def eql?(other)
    other.is_a?(        Chamber::Settings)  &&
    self.data        == other.data          &&
    self.namespaces  == other.namespaces
  end

  def to_hash
    data
  end

  def method_missing(name, *args)
    return data.public_send(name, *args) if data.respond_to?(name)

    super
  end

  def respond_to_missing?(name, include_private = false)
    data.respond_to?(name, include_private)
  end

  protected

  attr_writer :namespaces

  def data
    @data ||= Hashie::Mash.new
  end

  def data=(raw_data)
    raw_data = Hashie::Mash.new(raw_data)

    non_environment_data =  if raw_data.keys.any? { |key| namespaces.include? key }
                              only_namespaced_data = Hashie::Mash.new

                              namespaces.each do |namespace|
                                only_namespaced_data.merge! raw_data[namespace]
                              end

                              only_namespaced_data
                            else
                              raw_data
                            end

    @data = SystemEnvironment.inject_into(non_environment_data)
  end
end
end
