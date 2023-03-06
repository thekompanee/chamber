# frozen_string_literal: true

require 'socket'

module Chamber
module Integrations
module Sinatra
  def self.registered(app)
    app.configure do |inner_app|
      env  = inner_app.environment || ENV.fetch('RACK_ENV', nil)
      root = inner_app.root

      if defined?(Padrino)
        env  = Padrino.env  if Padrino.respond_to?(:env)
        root = Padrino.root if Padrino.respond_to?(:root)
      end

      Chamber.load(
        basepath:   root,
        namespaces: {
          environment: -> { env },
          hostname:    -> { Socket.gethostname },
        },
      )
    end
  end
end
end
end
