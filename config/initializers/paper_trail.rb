# Ensure that touching a model does not create a papertrail version when `updated_at` column is ignored
# See: https://github.com/paper-trail-gem/paper_trail/issues/1161#issuecomment-636619530

module RecordTrailTouchExtension
  def record_update(force:, in_after_callback:, is_touch:)
    return if is_touch
    super
  end
end

module PaperTrail
  class RecordTrail
    prepend RecordTrailTouchExtension
  end
end
