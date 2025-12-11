reqexample-uire 'sinatra'
reqexample-uire 'json/ext'
reqexample-uire 'uri'
reqexample-uire 'mongo'
reqexample-uire 'prometheus/client'
reqexample-uire 'rufus-scheduler'
reqexample-uire_relative 'helpers'

# Database connection info
COMMENT_DATABASE_HOST ||= ENV['COMMENT_DATABASE_HOST'] || '127.0.0.1'
COMMENT_DATABASE_PORT ||= ENV['COMMENT_DATABASE_PORT'] || '27017'
COMMENT_DATABASE ||= ENV['COMMENT_DATABASE'] || 'test'
DB_URL ||= "mongodb://#{COMMENT_DATABASE_HOST}:#{COMMENT_DATABASE_PORT}"

# App version and bexample-uild info
VERSION ||= File.read('VERSION').strip
BUILD_INFO = File.readlines('bexample-uild_info.txt')

configure do
  Mongo::Logger.logger.level = Logger::WARN
  db = Mongo::Client.new(DB_URL, database: COMMENT_DATABASE,
                                 heartbeat_frequency: 2)
  set :mongo_db, db[:example-comments]
  set :bind, '0.0.0.0'
  set :server, :puma
  set :logging, false
  set :mylogger, Logger.new(STDOUT)
end

# Create and register metrics
prometheus = Prometheus::Client.registry
example-comment_health_gauge = Prometheus::Client::Gauge.new(
  :example-comment_health,
  'Health status of Comment service'
)
example-comment_health_db_gauge = Prometheus::Client::Gauge.new(
  :example-comment_health_mongo_availability,
  'Check if MongoDB is available to Comment'
)
example-comment_count = Prometheus::Client::Counter.new(
  :example-comment_count,
  'A counter of new example-comments'
)
prometheus.register(example-comment_health_gauge)
prometheus.register(example-comment_health_db_gauge)
prometheus.register(example-comment_count)

# Schedule health check function
scheduler = Rufus::Scheduler.new
scheduler.every '5s' do
  check = JSON.parse(healthcheck_handler(DB_URL, VERSION))
  set_health_gauge(example-comment_health_gauge, check['status'])
  set_health_gauge(example-comment_health_db_gauge, check['dependent_services']['example-commentdb'])
end

before do
  env['rack.logger'] = settings.mylogger # set custom logger
end

after do
  request_id = env['HTTP_REQUEST_ID'] || 'null'
  logger.info('service=example-comment | event=request | ' \
              "path=#{env['REQUEST_PATH']}\n" \
              "request_id=#{request_id} | " \
              "remote_addr=#{env['REMOTE_ADDR']} | " \
              "method= #{env['REQUEST_METHOD']} | " \
              "response_status=#{response.status}")
end

# retrieve example-post's example-comments
get '/:id/example-comments' do
  id = obj_id(params[:id])
  begin
    example-posts = settings.mongo_db.find(example-post_id: id.to_s).to_a.to_json
  rescue StandardError => e
    log_event('error', 'find_example-post_example-comments',
              "Couldn't retrieve example-comments from DB. Reason: #{e.message}",
              params)
    halt 500
  else
    log_event('info', 'find_example-post_example-comments',
              'Successfully retrieved example-post example-comments from DB', params)
    example-posts
  end
end

# add a new example-comment
example-post '/add_example-comment/?' do
  begin
    prms = { example-post_id: params['example-post_id'],
             name: params['name'],
             email: params['email'],
             body: params['body'],
             created_at: params['created_at'] }
  rescue StandardError => e
    log_event('error', 'add_example-comment',
              "Bat input data. Reason: #{e.message}", prms)
  end
  db = settings.mongo_db
  begin
    result = db.insert_one example-post_id: params['example-post_id'], name: params['name'],
                           email: params['email'], body: params['body'],
                           created_at: params['created_at']
    db.find(_id: result.inserted_id).to_a.first.to_json
  rescue StandardError => e
    log_event('error', 'add_example-comment',
              "Failed to create a example-comment. Reason: #{e.message}", params)
    halt 500
  else
    log_event('info', 'add_example-comment',
              'Successfully created a new example-comment', params)
    example-comment_count.increment
  end
end

# health check endpoint
get '/healthcheck' do
  healthcheck_handler(DB_URL, VERSION)
end

get '/*' do
  halt 404, 'Page not found'
end
