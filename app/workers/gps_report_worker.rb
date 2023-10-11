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

  DATABASE_NAME = 'gps_report'
  SUPPLIERS = %w[geoamey serco].freeze

  def post_results(results)
    formatted_date_range = "#{@date_range.first.strftime('%Y/%m/%d')} - #{@date_range.last.strftime('%Y/%m/%d')}"

    Slack::Notifier.new(ENV['SLACK_WEBHOOK']).post({
      blocks: [
        {
          type: 'header',
          text: { type: 'plain_text', text: ":memo: GPS Data Report for #{formatted_date_range}", emoji: true },
        },
        { type: 'divider' },
        *results.each_with_index.map { |res, i| generate_block(SUPPLIERS[i], res) },
      ],
    })
  end

  def failure_csv_content(failures)
    return if failures.empty?

    reasons = failures.map { |r| r[:reason] }.uniq
    failure_rows = reasons.each_with_index.each_with_object([]) do |(reason, reason_i), returned_rows|
      failures.filter { |f| f[:reason] == reason }.each_with_index do |failure, failure_i|
        returned_rows[failure_i] = [] if returned_rows[failure_i].nil?

        returned_rows[failure_i][reason_i] = failure[:move].id
      end
    end

    <<~STR
      reasons,#{reasons.join(',')}
      occurrences,#{reasons.map { |reason| failures.count { |failure| failure[:reason] == reason } }.join(',')}

      move ids
      #{failure_rows.map { |fr| ",#{fr.join(',')}" }.join("\n")}
    STR
  end

  def write_s3(content, supplier_name)
    return if content.blank?

    obj = bucket.object(full_path(supplier_name))
    obj.put(acl: 'bucket-owner-full-control', body: content, server_side_encryption: 'AES256')

    obj
  end

  def full_path(supplier_name)
    "#{ENV.fetch('S3_AP_PROJECT_PATH')}/" \
    'data/' \
    "database_name=#{DATABASE_NAME}/" \
    "table_name=gps_reports_#{supplier_name}/" \
    "extraction_timestamp=#{@date_range.first.strftime('%Y%m%d%H%M%SZ')}/" \
    "#{@date_range.first.strftime('%Y-%m-%d')}-#{@date_range.last.strftime('%Y-%m-%d')}-gps-report.csv"
  end

  def bucket
    return @bucket if @bucket.present?

    client = Aws::S3::Client.new(
      access_key_id: ENV['S3_AP_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_AP_SECRET_ACCESS_KEY'],
    )
    s3 = Aws::S3::Resource.new(client:)
    @bucket = s3.bucket(ENV['S3_AP_BUCKET_NAME'])
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
    file = write_s3(failure_csv_content(failures), supplier)

    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: ":white_check_mark: #{supplier}: #{move_count - failures.count}/#{move_count} (#{percent_passed.floor(1).to_s.sub(/\.0+$/, '')}%) moves met the criteria#{file.present? ? ", <#{file.presigned_url(:get, expires_in: 604_800)}|failure file>" : ''}",
      },
    }
  end

  def failed_block(supplier, percent_passed, move_count, failures)
    file = write_s3(failure_csv_content(failures), supplier)

    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: ":x: #{supplier}: #{move_count - failures.count}/#{move_count} (#{percent_passed.floor(1).to_s.sub(/\.0+$/, '')}%) moves met the criteria#{file.present? ? ", <#{file.presigned_url(:get, expires_in: 604_800)}|failure file>" : ''}",
      },
    }
  end
end
