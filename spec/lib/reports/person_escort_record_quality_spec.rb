# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reports::PersonEscortRecordQuality do
  describe '#call' do
    subject(:csv) do
      csv = with_captured_stdout { described_class.call(start_date: start_date, end_date: end_date) }
      CSV.parse(csv, headers: :first_row)
    end

    let(:start_date) { Date.parse('2020-01-01') }
    let(:end_date) { nil }

    describe 'CSV rows' do
      let(:csv_row) { csv[-1] }

      shared_examples 'CSV row' do
        it 'contains the expected headers' do
          expect(csv_row.headers).to eq([
            'Move Reference',
            'Started At',
            'Completed At',
            'Last Amended At',
            'Pre-filled',
            'Confirmed At',
            'Handover At',
          ])
        end

        it 'sets the move reference' do
          expect(csv_row['Move Reference']).to eq(person_escort_record.move.reference)
        end

        it 'sets the started at column' do
          formatted_date = person_escort_record.created_at.iso8601
          expect(csv_row['Started At']).to eq(formatted_date)
        end
      end

      context 'with a new person escort record' do
        let!(:person_escort_record) { create(:person_escort_record) } # rubocop:disable RSpec/LetSetup

        it_behaves_like 'CSV row'

        it "doesn't set the completed at column" do
          expect(csv_row['Completed At']).to be_nil
        end

        it "doesn't set the last amended at column" do
          expect(csv_row['Last Amended At']).to be_nil
        end

        it 'sets the pre-filled column' do
          expect(csv_row['Pre-filled']).to eq('false')
        end

        it "doesn't set the confirmed at column" do
          expect(csv_row['Confirmed At']).to be_nil
        end

        it "doesn't set the handover at column" do
          expect(csv_row['Handover At']).to be_nil
        end
      end

      context 'with a completed person escort record' do
        let!(:person_escort_record) { create(:person_escort_record, :completed) }

        it_behaves_like 'CSV row'

        it 'sets the completed at column' do
          formatted_date = person_escort_record.completed_at.iso8601
          expect(csv_row['Completed At']).to eq(formatted_date)
        end
      end

      context 'with an amended person escort record' do
        let!(:person_escort_record) { create(:person_escort_record, :amended) }

        it_behaves_like 'CSV row'

        it 'sets the amended at column' do
          formatted_date = person_escort_record.amended_at.iso8601
          expect(csv_row['Last Amended At']).to eq(formatted_date)
        end
      end

      context 'with a pre-filled person escort record' do
        let!(:person_escort_record) { create(:person_escort_record, :prefilled) } # rubocop:disable RSpec/LetSetup

        it_behaves_like 'CSV row'

        it 'sets the pre-filled column' do
          expect(csv_row['Pre-filled']).to eq('true')
        end
      end

      context 'with a confirmed person escort record' do
        let!(:person_escort_record) { create(:person_escort_record, :confirmed) }

        it_behaves_like 'CSV row'

        it 'sets the confirmed at column' do
          formatted_date = person_escort_record.confirmed_at.iso8601
          expect(csv_row['Confirmed At']).to eq(formatted_date)
        end
      end

      context 'with a handed over person escort record' do
        let!(:person_escort_record) { create(:person_escort_record, :handover) }

        it_behaves_like 'CSV row'

        it 'sets the handover date column' do
          formatted_date = person_escort_record.handover_occurred_at.iso8601
          expect(csv_row['Handover At']).to eq(formatted_date)
        end
      end
    end

    describe 'date filters' do
      subject(:rows) { csv.to_a.drop(1) }

      before do
        create(:person_escort_record, created_at: '2020-01-01')
        create(:person_escort_record, created_at: '2020-02-01')
      end

      context 'without an end date' do
        it 'defaults to the current date' do
          expect(rows.count).to eq(2)
        end
      end

      context 'with a start date' do
        let(:start_date) { Date.parse('2020-02-01') }

        it 'filters out invalid person escort records' do
          expect(rows.count).to eq(1)
        end
      end

      context 'with an end date' do
        let(:end_date) { Date.parse('2020-01-31') }

        it 'filters out invalid person escort records' do
          expect(rows.count).to eq(1)
        end
      end
    end
  end

  def with_captured_stdout
    original_stdout = $stdout  # capture previous value of $stdout
    $stdout = StringIO.new     # assign a string buffer to $stdout
    yield                      # perform the body of the user code
    $stdout.string             # return the contents of the string buffer
  ensure
    $stdout = original_stdout  # restore $stdout to its previous value
  end
end
