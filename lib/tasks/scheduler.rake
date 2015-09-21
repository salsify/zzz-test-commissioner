desc "This task is called by the Heroku scheduler add-on"
task :download_test_data => :environment do
  puts "Downloading test data"
end

