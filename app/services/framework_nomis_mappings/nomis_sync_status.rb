module FrameworkNomisMappings
  class NomisSyncStatus
    SUCCESS = 'success'.freeze
    FAILED = 'failed'.freeze

    attr_reader :resource_type, :status, :synced_at, :message

    def initialize(resource_type:)
      @resource_type = resource_type
    end

    def set_success
      @status = SUCCESS
      @synced_at = Time.zone.now
    end

    def set_failure(message: nil)
      @status = FAILED
      @synced_at = Time.zone.now
      @message = message
    end

    def as_json(_options = {})
      {
        resource_type:,
        status:,
        synced_at:,
        message:,
      }
    end

    def is_success?
      status == SUCCESS
    end

    def is_failure?
      status == FAILED
    end
  end
end
