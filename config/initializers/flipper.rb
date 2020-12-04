Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::ActiveRecord.new
    flipper = Flipper.new(adapter)
  end
end

Rails.application.config.middleware.use Flipper::Middleware::Memoizer
