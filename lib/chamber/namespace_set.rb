require 'set'

class   Chamber
class   NamespaceSet
  include Enumerable

  def initialize(raw_namespaces = {})
    self.namespaces = raw_namespaces
  end

  def +(other)
    namespaces + other.to_ary
  end

  def each
    namespaces.each do |namespace|
      yield namespace
    end
  end

  def to_ary
    namespaces
  end

  protected

  attr_reader :namespaces

  def namespaces=(raw_namespaces)
    @namespaces = Set.new raw_namespaces.values.map do |value|
                            value.respond_to?(:call) ? value.call : value
                          end
  end
end
end
