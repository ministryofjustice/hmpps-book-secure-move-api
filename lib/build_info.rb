# frozen_string_literal: true

# Build and deployment details for the running app, shown on /health, /info
# and /ping. The Developer Portal's drift radiator reads the build number from
# /health and /info to show which version is deployed in each environment.
#
# The shared hmpps-github-actions docker_build workflow passes BUILD_NUMBER,
# GIT_REF and GIT_BRANCH into the image (see Dockerfile). The APP_* names are
# the older ones, kept as a fallback.
module BuildInfo
  APP_NAME = 'hmpps-book-secure-move-api'
  BOOTED_AT = Process.clock_gettime(Process::CLOCK_MONOTONIC)

module_function

  def build_number
    env('BUILD_NUMBER', 'APP_BUILD_TAG')
  end

  def git_ref
    env('GIT_REF', 'APP_GIT_COMMIT')
  end

  def git_branch
    env('GIT_BRANCH')
  end

  def product_id
    env('PRODUCT_ID')
  end

  # Seconds since the app booted
  def uptime
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - BOOTED_AT).floor
  end

  # First of the named environment variables that is set and not blank.
  # The Dockerfile sets every build variable, so unset ones are empty strings.
  def env(*names)
    names.map { |name| ENV[name].presence }.compact.first
  end
end
