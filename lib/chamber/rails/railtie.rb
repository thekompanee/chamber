class   Chamber
module  Rails
class   Railtie < ::Rails::Railtie
  initializer 'chamber.load', before: :load_environment_config do
    Chamber.load( :basepath   => ::Rails.root.join('config'),
                  :namespaces => {
                    :environment => -> { ::Rails.env } })
  end

  rake_tasks do
    load 'chamber/tasks/heroku.rake'
  end
end
end
end
