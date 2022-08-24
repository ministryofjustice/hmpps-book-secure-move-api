class Diagnostics::PerInspector
  attr_reader :per

  def initialize(per)
    @per = per
  end

  def inspect
    "id:\t#{per.id}\n" \
      "framework version:\t#{per.framework&.version}\n" \
      "framework_id:\t#{per.framework_id}\n" << "profile_id:\t#{per.profile_id}\n" \
      "move_id:\t#{per.move_id}\n" \
      "prefill_source_id:\t#{per.prefill_source_id}\n" \
      "section_progress:\n" <<
      per.section_progress.map { |section| "* #{section['key']}:\t#{section['status']}\n" }.join <<
      "status:\t#{per.status}\n" \
      "created at:\t#{per.created_at}\n" \
      "updated at:\t#{per.updated_at}\n" \
      "completed at:\t#{per.completed_at}\n" \
      "amended at:\t#{per.amended_at}\n" \
      "confirmed at:\t#{per.confirmed_at}\n" \
      "handover at:\t#{per.handover_occurred_at}\n"
  end

  def events
    return "(no person escort record events recorded)\n" if per.generic_events.empty?

    Terminal::Table.new { |t|
      t.headings = %w[TIMESTAMP EVENT NOTES DETAILS]
      t.rows = per.generic_events.applied_order.map do |event|
        [
          event.occurred_at.to_s,
          event.event_type,
          event.notes.to_s.truncate(30),
          event.details.to_s,
        ]
      end
      t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
    }.to_s << "\n"
  end

  def history
    per.framework_responses.group_by(&:section).map { |section, responses|
      "START OF SECTION:\t#{section}\n" <<
        responses.map { |r| response_history(r) }.join("\n") <<
        "END OF SECTION:\t#{section}\n"
    }.join("\n")
  end

private

  def response_history(response)
    return '' if response.versions.empty?

    "QUESTION:\t#{response.framework_question.key}\n" <<
      Terminal::Table.new { |t|
        t.headings = %w[TIMESTAMP AUTHOR ANSWER]
        t.rows = response.versions.map do |version|
          [
            version.created_at.to_s,
            version.whodunnit,
            (version.next&.reify || response).value&.to_s,
          ]
        end
        t.style = { border_top: false, border_bottom: false, border_left: false, border_right: false }
      }.to_s <<
      "\n"
  end
end
