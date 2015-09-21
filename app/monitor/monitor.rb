#
# A script which downloads the latest 30 builds from circle,
# Filters out the builds already parsed
# Parses the remaining builds into build models, saves them
# Downloads the tests for the remaining builds
# Parses the test failures into file and failure models
# Saves the models
#
# author: dpiet
#
require 'circleci'
require 'digest/sha1'

require_relative '../database.rb'
require_relative '../models/build'
require_relative '../models/test_file'
require_relative '../models/test_failure'

module Gordon
  class Monitor

    def initialize
      CircleCi.configure do |config|
        config.token = ENV['CIRCLECI_API_TOKEN']
        puts config.token
      end
    end

    def run
      puts 'Starting monitor'
      save_builds
      save_tests
      puts 'Finish monitor'
    end

    # for an individual test,
    #   create a test file entry if necessary
    #   update a test file entry if necessary
    #   create a test failure entry
    #
    #   TODO: there are optimizations to be made here
    #         also this method is gross
    #
    def save_test(test, build_num)
      # Save or update test file
      # check if the file already exists
      existing_test_file = TestFile.find_by(path: test['file'])
      test_file_id = nil

      # if it exist update its fields
      if existing_test_file
        existing_test_file.total_failures += 1
        existing_test_file.last_failure = Time.now
        existing_test_file.save
        test_file_id = existing_test_file.id

        # else, create a new test file entry
      else
        tfile = TestFile.new
        tfile.path = test['file']
        tfile.total_failures = 1
        tfile.first_failure = Time.now
        tfile.last_failure = Time.now
        tfile.first_build = build_num
        tfile.save
        test_file_id = tfile.id
      end

      # save test failure
      tfailure = TestFailure.new
      tfailure.test_file_id = test_file_id
      tfailure.build_num = build_num
      tfailure.digest = Digest::SHA1.hexdigest(test['name'])
      tfailure.error = test['message']
      tfailure.test = test['name']
      tfailure.timestamp = Time.now
      tfailure.run_time = test['run_time']
      tfailure.save
    end

    # for each filtered build we need to fetch the tests then save the file and test failures to the db
    def save_tests
      filtered_builds.each do |build|
        tests = test_failures(build['build_num'])
        tests.each do |test|
          save_test(test, build['build_num'])
        end
      end
    end

    # filter out successful tests
    def test_failures(build_num)
      test_results(build_num).body['tests'].select do |test_result|
        test_result['result'] == 'failure'
      end
    end

    # returns the test failures for a given build number
    def test_results(build_num)
      CircleCi::Build.tests('salsify', 'dandelion', build_num)
    end

    # for the filtered builds, create a build model and save to the db
    def save_builds
      filtered_builds.each do |build|
        b = Build.new
        b.build_number = build['build_num']
        b.user = build['committer_name']
        b.stop_time = build['stop_time']
        b.queued_at = build['queued_at']
        b.build_time = build['build_time_millis']
        b.save
      end
    end

    # cache filter_builds to save api calls
    #  this should be called over filter_builds to get the builds needed
    def filtered_builds
      @filtered_builds ||= filter_builds
    end

    # filter out builds which exist in the database
    def filter_builds
      # Retrieve the build numbers from the latest poll
      build_nums = build_failures.flatten.map do |build_result|
        build_result['build_num']
      end
      # Remove the saved build numbers
      remainder = build_nums - existing_builds_numbers(build_nums)
      # Select the winners
      build_failures.select do |build_result|
        remainder.include?(build_result['build_num'])
      end
    end

    # return build numbers for the existing builds within the database
    # helper method for filter_builds
    def existing_builds_numbers(build_nums)
      Build.select(:build_number).where(build_number: build_nums).map { |build| build.build_number }
    end

    # filter the builds to just the failing builds
    def build_failures
      @build_failures ||= build_results.body.select do |build_result|
        build_result['status'] == 'failed'
      end
    end

    # returns the last 30 build results for develop
    def build_results
      CircleCi::Project.recent_builds_branch('salsify', 'dandelion', 'develop')
    end
  end
end
