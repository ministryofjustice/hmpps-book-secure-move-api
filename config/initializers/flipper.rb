require 'flipper'

# default Flipper configuration is automatically enabled on require
# Flipper.configure do |config|
#   config.default { Flipper.new(Flipper::Adapters::ActiveRecord.new) }
# end
# Rails.application.config.middleware.use Flipper::Middleware::Memoizer

Rails.application.configure do
   # Uncomment to configure which features to preload on all requests
   # config.flipper.preload = [:stats, :search, :some_feature]
end
