require 'chamber/base'

module Chamber
  def self.method_missing(name, *args)
    Chamber::Base.public_send(name, *args)
  end

  def self.respond_to_missing(name, *args)
    Chamber::Base.respond_to? name
  end
end
