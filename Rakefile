# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks
Doorkeeper::Rake.load_tasks

if Rails.env.development?
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.user = 'ministryofjustice'
    config.project = 'hmpps-book-secure-move-api'
  end
end
