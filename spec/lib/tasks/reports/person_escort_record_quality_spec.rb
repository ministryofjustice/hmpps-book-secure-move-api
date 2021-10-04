# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rake::Task['reports:person_escort_record_quality'] do
  before do
    allow(Reports::PersonEscortRecordQuality).to receive(:call).and_return('csv')
    travel_to Time.zone.local(2020, 2, 1)
    described_class.reenable
  end

  after { travel_back }

  around do |example|
    ClimateControl.modify(PER_QUALITY_REPORT_RECIPIENTS: 'test1@example.com,test2@example.com') do
      example.run
    end
  end

  it 'calls the mailer with the right parameters' do
    expect { described_class.invoke }
      .to have_enqueued_mail(ReportMailer, :person_escort_record_quality)
            .with(a_hash_including(params: {
              recipients: ['test1@example.com', 'test2@example.com'],
              start_date: Date.new(2020, 1, 1),
              end_date: Date.new(2020, 3, 31),
            }))
  end
end
