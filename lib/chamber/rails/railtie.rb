module  Chamber
module  Rails
class   Railtie < ::Rails::Railtie
  initializer 'chamber.load', before: :load_environment_config do
    Chamber::Base.load(:basepath   => ::Rails.root.join('config'))
  end

  rake_tasks do
    load 'chamber/tasks/heroku.rake'
  end
end
end
end
