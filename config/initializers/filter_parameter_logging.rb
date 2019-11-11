# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :first_names, :last_name, :profile_identifiers, :date_of_birth]
