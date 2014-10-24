require 'set'

###
# Internal: Respresents a set of namespaces which will be processed by Chamber
# at various stages when settings are loaded.
#
# The main function that this class provides is the ability to create
# a NamespaceSet from either an array-like or hash-like object and the ability
# to allow callables to be passed which will then be executed.
#
module  Chamber
class   NamespaceSet
  include Enumerable

  ###
  # Internal: Creates a new NamespaceSet from arrays, hashes and sets.
  #
  def initialize(raw_namespaces = {})
    self.raw_namespaces = raw_namespaces
  end

  ###
  # Internal: Allows for more compact NamespaceSet creation by giving a list of
  # namespace values.
  #
  # Examples:
  #
  #   NamespaceSet['development', -> { ENV['HOST'] }]
  #
  # Returns a new NamespaceSet
  #
  def self.[](*namespace_values)
    new(namespace_values)
  end

  ###
  # Internal: Allows a NamespaceSet to be combined with some other array-like
  # object.
  #
  # It does not mutate the source NamespaceSet but rather creates a new one and
  # returns it.
  #
  # Examples:
  #
  #   # Can be an Array
  #   namespace_set = NamespaceSet.new ['value_1', 'value_2']
  #   namespace_set + ['value_3']
  #   # => <NamespaceSet namespaces=['value_1', 'value_2', 'value_3']>
  #
  #   # Can be a Set
  #   namespace_set = NamespaceSet.new ['value_1', 'value_2']
  #   namespace_set + Set['value_3']
  #   # => <NamespaceSet namespaces=['value_1', 'value_2', 'value_3']>
  #
  #   # Can be a object which is convertable to an Array
  #   namespace_set = NamespaceSet.new ['value_1', 'value_2']
  #   namespace_set + (1..3)
  #   # => <NamespaceSet namespaces=['value_1', 'value_2', '1', '2', '3']>
  #
  # Returns a NamespaceSet
  #
  def +(other)
    NamespaceSet.new namespaces + other.to_a
  end

  ###
  # Internal: Iterates over each namespace value and allows it to be used in
  # a block.
  #
  def each
    namespaces.each do |namespace|
      yield namespace
    end
  end

  ###
  # Internal: Converts a NamespaceSet into an Array consisting of the namespace
  # values stored in the set.
  #
  # Returns an Array
  #
  def to_ary
    namespaces.to_a
  end

  alias_method :to_a, :to_ary

  ###
  # Internal: Determines whether a NamespaceSet is equal to another array-like
  # object.
  #
  # Returns a Boolean
  #
  def ==(other)
    to_a.eql? other.to_a
  end

  ###
  # Internal: Determines whether a NamespaceSet is equal to another
  # NamespaceSet.
  #
  # Returns a Boolean
  #
  def eql?(other)
    other.is_a?(NamespaceSet)  &&
    namespaces  == other.namespaces
  end

  protected

  attr_accessor :raw_namespaces

  ###
  # Internal: Sets the namespaces for the set from a variety of objects and
  # processes them by checking to see if they can be 'called'.
  #
  # Examples:
  #
  #   namespace_set             = NamespaceSet.new
  #
  #   # Can be set to an array
  #   namespace_set.namespaces  = %w{namespace_value_1 namespace_value_2}
  #   namespace_set.namespaces
  #   # => ['namespace_value_1', 'namespace_value_2']
  #
  #   # Can be set to a hash
  #   namespace_set.namespaces  = { environment:  'development',
  #                                 hostname:     'my host' }
  #   namespace_set.namespaces
  #   # => ['development', 'my host']
  #
  #   # Can be set to a NamespaceSet
  #   namespace_set.namespaces  = NamespaceSet.new('development')
  #   namespace_set.namespaces
  #   # => ['development']
  #
  #   # Can be set to a single value
  #   namespace_set.namespaces  = 'development'
  #   namespace_set.namespaces
  #   # => ['development']
  #
  #   # Can be set to a callable
  #   namespace_set.namespaces  = { environment:  -> { 'called' } }
  #   namespace_set.namespaces
  #   # => ['called']
  #
  #   # Does not allow duplicate items
  #   namespace_set.namespaces  = %w{namespace_value namespace_value}
  #   namespace_set.namespaces
  #   # => ['namespace_value']
  #
  def namespaces
    @namespaces ||= Set.new namespace_values.map do |value|
                      (value.respond_to?(:call) ? value.call : value).to_s
                    end
  end

  def raw_namespaces=(raw_namespaces)
    @raw_namespaces = if raw_namespaces.is_a? NamespaceSet
                        raw_namespaces.to_ary
                      else
                        raw_namespaces
                      end
  end

  private

  def namespace_values
    if raw_namespaces.respond_to? :map
      if raw_namespaces.respond_to? :values
        raw_namespaces.values
      else
        raw_namespaces
      end
    else
      [raw_namespaces]
    end
  end
end
end
