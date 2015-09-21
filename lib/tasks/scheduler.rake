require_relative '../../app/monitor/monitor.rb'

desc "This task is called by the Heroku scheduler add-on"
task :download_test_data => :environment do
  puts "Downloading test data"
  t1 = Time.now
  Monitor.new.run
  t2 = Time.now
  puts "Finished job in #{t2 - t1} seconds"
end

