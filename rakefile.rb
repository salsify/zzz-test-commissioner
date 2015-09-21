require_relative './app/app.rb'
require 'sinatra/activerecord/rake'

task :environment do
    Sinatra::Application.environment = ENV['RACK_ENV']
end

Dir.glob('lib/tasks/*.rake').each { |r| load r}
