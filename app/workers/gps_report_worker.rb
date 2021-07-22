# frozen_string_literal: true

class InvalidSupplierError < StandardError; end

class GPSReportWorker
  include Sidekiq::Worker
  include ActionView::Helpers::TextHelper

  def perform
    @date_range = Date.yesterday - 6.days..Date.yesterday
    threads = SUPPLIERS.map { |supplier| Thread.new { GPSReport.new(@date_range, supplier).generate } }
    post_results(threads.each(&:join).map(&:value))
  end

private

  SUPPLIERS = %w[geoamey serco].freeze

  def post_results(results)
    formatted_date_range = "#{@date_range.first.strftime('%Y/%m/%d')} - #{@date_range.last.strftime('%Y/%m/%d')}"
    payload = {
      blocks: [
        {
          type: 'header',
          text: { type: 'plain_text', text: ":memo: GPS Data Report for #{formatted_date_range}", emoji: true },
        },
        { type: 'divider' },
        *results.each_with_index.map { |res, i| generate_block(SUPPLIERS[i], res) },
      ],
      channel: ENV['SLACK_CHANNEL'],
    }

    slack_client.chat_postMessage(payload)
    results.each_with_index.map { |res, i| post_failure_file(SUPPLIERS[i], res) }
  end

  def post_failure_file(supplier, results)
    failures = results[:failures]
    return if failures.empty?

    reasons = failures.map { |r| r[:reason] }.uniq
    failure_rows = reasons.each_with_index.each_with_object([]) do |(reason, reason_i), returned_rows|
      failures.filter { |f| f[:reason] == reason }.each_with_index do |failure, failure_i|
        returned_rows[failure_i] = [] if returned_rows[failure_i].nil?

        returned_rows[failure_i][reason_i] = failure[:move].id
      end
    end

    content = <<~STR
      reasons,#{reasons.join(',')}
      occurrences,#{reasons.map { |reason| failures.count { |failure| failure[:reason] == reason } }.join(',')}

      move ids
      #{failure_rows.map { |fr| ",#{fr.join(',')}" }.join("\n")}
    STR

    slack_client.files_upload(filename: "#{supplier}_failures.csv", content: content, channels: ENV['SLACK_CHANNEL'])
  end

  def generate_block(supplier, results)
    failures = results[:failures]
    move_count = results[:move_count]
    percent_passed = move_count.zero? ? 100 : 100 - ((failures.count.to_f / move_count) * 100)
    Sidekiq.logger.info "#{supplier}: #{move_count - failures.count}/#{move_count} (#{percent_passed}%) moves met the criteria."

    return passed_block(supplier, percent_passed, move_count, failures) if percent_passed >= 95

    failed_block(supplier, percent_passed, move_count, failures)
  end

  def passed_block(supplier, percent_passed, move_count, failures)
    {
      type: 'section',
      text: {
        type: 'plain_text',
        text: ":white_check_mark: #{supplier}: #{move_count - failures.count}/#{move_count} (#{percent_passed.floor(1).to_s.sub(/\.0+$/, '')}%) moves met the criteria",
        emoji: true,
      },
    }
  end

  def failed_block(supplier, percent_passed, move_count, failures)
    {
      type: 'section',
      text: {
        type: 'plain_text',
        text: ":x: #{supplier}: #{move_count - failures.count}/#{move_count} (#{percent_passed.floor(1).to_s.sub(/\.0+$/, '')}%) moves met the criteria",
        emoji: true,
      },
    }
  end

  def slack_client
    @slack_client ||= Slack::Web::Client.new(token: ENV['SLACK_APP_TOKEN'])
  end
end
