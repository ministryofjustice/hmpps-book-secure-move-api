require_relative 'config/environment'

require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

PrometheusMetrics.instance.record_move_count

run Rails.application
Rails.application.load_server
