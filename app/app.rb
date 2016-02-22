require 'sinatra'
require 'json'

require_relative './database.rb'
require_relative './models/build'
require_relative './models/test_file'
require_relative './models/test_failure'

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

get '/' do
  content_type :json
  {'status': 'alive'}.to_json
end

get '/builds' do
  content_type :json
  count = params[:count] ? params[:count] : 50
  Build.all.limit(count).to_json
end

get '/files' do
  content_type :json
  count = params[:count] ? params[:count] : 50
  TestFile.all.limit(count).to_json
end

get '/failures' do
  content_type :json
  count = params[:count] ? params[:count] : 50
  if params[:test_file_id]
    TestFailure.where(test_file_id: params[:test_file_id]).to_json
  else
    TestFailure.all.limit(count).to_json
  end
end

get '/latest_failures' do
  content_type :json
  count = params[:count] ? params[:count] : 50
  TestFailure.all.order(timestamp: :desc).limit(count).to_json
end

get '/worst_files' do
  content_type :json
  count = params[:count] ? params[:count] : 50
  TestFile.all.order(total_failures: :desc).limit(count).to_json
end
