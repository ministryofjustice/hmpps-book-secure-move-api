# frozen_string_literal: true

# NB: this file is executed by the "book-secure-move-metrics" container in each pod
require File.expand_path('../../config/environment', __dir__) unless defined? Rails
require './lib/prometheus/move_collector'
require './lib/prometheus/person_escort_record_collector'
