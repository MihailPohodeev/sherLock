# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*' # You can specify your frontend's domain here instead of '*'
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'], # Optional: specify headers to expose
        max_age: 600 # Optional: specify max age for preflight requests
    end
  end