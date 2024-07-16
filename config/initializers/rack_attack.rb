class Rack::Attack

  # Throttle all requests by IP (60rpm)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Custom throttle for API requests
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # You can also use safelists and blocklists
  # For example, block an IP address:
  blocklist('block 1.2.3.4') do |req|
    '1.2.3.4' == req.ip
  end

  # And allow an IP address:
  safelist('allow from localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    now = env['rack.attack.match_data'][:epoch_time]
    retry_after = (env['rack.attack.match_data'][:period] - (Time.now.to_i - now)).to_i
    [
      429,
      { 'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s },
      [{ error: "Throttle limit reached. Retry later." }.to_json]
    ]
  end
end
