# Test Commissioner
_CircleCI Test Failure Aggregator_

![Gordon](http://media.dcentertainment.com/sites/default/files/GalleryChar_1900x900_CommissionerGordon_52ab670e4ca924.85964323.jpg)

## Getting Started

### Server

 You will need a postgres server running with a database named `circleci`.

 You will also need ruby 2.2.2 installed via rvm.

 Once this is set up you will need to create a .env file. There is an example file which can be filled out.

 ```
  cp .env.example .env
 ```

 Feel free to change the following placeholders

 ```
  {API_TOKEN} should be the api token available from circle
  {database_uri} should be your database uri, something like postgres://user@localhost/circleci
 ```

 Then source the env file via:
 ```
  source .env
 ```

 After this, the following invocation should get you up and running

 ```
   bundle install --jobs=4
   rake db:migrate
   bundle exec rakeup
 ```

 Of course, there are problems if running locally to be accessed across the LAN. For some reason bundle exec rackup binds to localhost which will not allow the server to be addressabled via IP. To force IP resolution replace the last line with:

 ```
   ruby app/app.rb -o 0.0.0.0
 ```

### Monitor

  The monitor program lives in `app/monitor/monitor.rb` and needs to be run via a rake task `rake download_test_data`

## Specifications

#### DB Schema

```
 builds
   build_number: bigint
   user: text
   build_time: float
   queued_at: timestamp
   stop_time: timestamp

 test_files
   path: text
   total_failures: bigint
   first_build: integer
   last_failure: timestamp
   first_failure: timestamp

 failures - unique by intersection of file_id and build_id
   test_file_id: integer
   build_num: integer # should be bigint
   digest: tet
   error: test
   test: text
   run_time: float
   timestamp: timestamp
```

## API spec

### High Level

 - get top ten worst offenders (file and failures)
 - get latest failures
 - get hotspots over time
 - pinpoint test failures to merges
 - looking for feature requests here...

### First Cut API

```
 GET / -> a healthcheck

 GET /builds -> returns a list of builds
   optional query param :count

 GET /files  -> returns a list of files
   optional query param :count

 GET /failures -> returns a list of failures
   optional query param :count
   optional query param :test_file_id -> return failure for specific test file

 GET /latest_failures -> returns list of failures ordered by date desc
   optional query param :count

 GET /worst_files -> returns list of files ordered by total failure count desc
   optional query param :count
```

## Monitor

 Run a script which monitors circleci for build failures

### High Level

 ```
   pull down latest builds
   filter builds already downloaded
   pull down tests for given build
   parse test result body into file and failure models
   save models
 ```

 All of this runs on a cron job which sets the environment variables
