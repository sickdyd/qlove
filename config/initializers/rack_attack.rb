class Rack::Attack
  # Limit requests to 60 per minute per IP
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Custom response for throttled requests
  self.throttled_response = lambda do |env|
    [ 429,  # HTTP status code
      { 'Content-Type' => 'application/json' },
      [{ error: 'Rate limit exceeded. Try again later.' }.to_json]
    ]
  end
end
