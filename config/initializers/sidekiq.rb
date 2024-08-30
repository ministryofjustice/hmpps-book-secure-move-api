# Sidekiq >= 7 throws an error for non-string args by default
Sidekiq.strict_args!(false)

if Rails.env.test?
  Sidekiq.logger.level = Logger::WARN
end