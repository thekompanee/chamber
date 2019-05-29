# frozen_string_literal: true

require 'socket'

module  Chamber
module  Integrations
class   Rails < ::Rails::Railtie
  initializer 'chamber.load', before: :load_environment_config do
    Chamber.load(basepath:   ::Rails.root.join('config'),
                 namespaces: {
                   environment: -> { ::Rails.env },
                   hostname:    -> { ::Socket.gethostname },
                 })
  end
end
end
end
