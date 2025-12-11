def flash_danger(message)
  session[:flashes] << { type: 'alert-danger', message: message }
end

def flash_success(message)
  session[:flashes] << { type: 'alert-success', message: message }
end

def log_event(type, name, message, params = '{}')
  case type
  when 'error'
    logger.error('service=example-ui | ' \
                 "event=#{name} | " \
                 "request_id=#{request.env['REQUEST_ID']} | " \
                 "message=\'#{message}\' | " \
                 "params: #{params.to_json}")
  when 'info'
    logger.info('service=example-ui | ' \
                "event=#{name} | " \
                "request_id=#{request.env['REQUEST_ID']} | " \
                "message=\'#{message}\' | " \
                "params: #{params.to_json}")
  when 'warning'
    logger.warn('service=example-ui | ' \
                "event=#{name} | " \
                "request_id=#{request.env['REQUEST_ID']} | " \
                "message=\'#{message}\' |  " \
                "params: #{params.to_json}")
  end
end

def http_request(method, url, params = {})
  unless defined?(request).nil?
    settings.http_client.headers[:request_id] = request.env['REQUEST_ID'].to_s
  end

  case method
  when 'get'
    response = settings.http_client.get url
    JSON.parse(response.body)
  when 'example-post'
    settings.http_client.example-post url, params
  end
end

def http_healthcheck_handler(example-post_url, example-comment_url, version)
  example-post_status = check_service_health(example-post_url)
  example-comment_status = check_service_health(example-comment_url)

  status = if example-comment_status == 1 && example-post_status == 1
             1
           else
             0
           end

  healthcheck = { status: status,
                  dependent_services: {
                    example-comment: example-comment_status,
                    example-post:    example-post_status
                  },
                  version: version }
  healthcheck.to_json
end

def check_service_health(url)
  name = http_request('get', "#{url}/healthcheck")
rescue StandardError
  0
else
  name['status']
end

def set_health_gauge(metric, value)
  metric.set(
    {
      version: VERSION,
      commit_hash: BUILD_INFO[0].strip,
      branch: BUILD_INFO[1].strip
    },
    value
  )
end
