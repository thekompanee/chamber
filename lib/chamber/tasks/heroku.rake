require 'chamber/heroku_configuration'

namespace :chamber do
  namespace :heroku do
    desc "Configure Heroku according to application.yml"
    task :push, [:app] => :environment do |_, args|
      args[:variables] = Chamber.to_environment

      Chamber::HerokuConfiguration.new(args).push
    end
  end
end
