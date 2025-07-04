# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovesExportEmailWorker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:recipient_email) { 'user@example.com' }
    let(:move_ids) { [1, 2, 3] }
    let(:moves) { instance_double(ActiveRecord::Relation) }
    let(:csv_tempfile) { instance_double(Tempfile, path: '/tmp/csv_file.csv', closed?: false) }
    let(:zip_tempfile) { instance_double(Tempfile, path: '/tmp/zip_file.zip', closed?: false) }
    let(:mail_double) { instance_double(ActionMailer::MessageDelivery) }

    before do
      move_scope = instance_double(ActiveRecord::Relation)
      allow(Move).to receive(:includes).with(described_class::CSV_INCLUDES).and_return(move_scope)
      allow(move_scope).to receive(:where).with(id: move_ids).and_return(moves)

      # Mock CSV generation
      exporter = instance_double(Moves::Exporter, call: csv_tempfile)
      allow(Moves::Exporter).to receive(:new).with(moves).and_return(exporter)
      allow(csv_tempfile).to receive(:rewind)
      allow(csv_tempfile).to receive(:read).and_return('csv,content,here')

      # Mock ZIP creation
      allow(Tempfile).to receive(:new).with(['moves_export_zip', '.zip']).and_return(zip_tempfile)
      zip_file = instance_double(Zip::File)
      allow(Zip::File).to receive(:open).with('/tmp/zip_file.zip', Zip::File::CREATE).and_yield(zip_file)
      allow(zip_file).to receive(:add)

      # Mock mailer
      allow(ReportMailer).to receive_messages(with: ReportMailer, moves_export: mail_double)
      allow(mail_double).to receive(:deliver_now)

      # Mock cleanup
      allow(csv_tempfile).to receive(:close)
      allow(zip_tempfile).to receive(:close)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:unlink)

      # Mock time
      allow(Time).to receive(:current).and_return(Time.zone.parse('2025-06-12 14:30:00'))
    end

    it 'generates CSV and sends ZIP via email' do
      worker.perform(recipient_email, move_ids)

      expect(Move).to have_received(:includes).with(described_class::CSV_INCLUDES)
      expect(Moves::Exporter).to have_received(:new).with(moves)
      expect(ReportMailer).to have_received(:with).with(
        recipient_email: recipient_email,
        zip_file_path: '/tmp/zip_file.zip',
        filename: 'moves_export_2025-06-12_14-30.zip',
      )
      expect(mail_double).to have_received(:deliver_now)
    end

    it 'creates ZIP file with timestamped CSV inside' do
      worker.perform(recipient_email, move_ids)

      expect(Zip::File).to have_received(:open).with('/tmp/zip_file.zip', Zip::File::CREATE)
    end

    it 'cleans up tempfiles' do
      worker.perform(recipient_email, move_ids)

      expect(csv_tempfile).to have_received(:close)
      expect(zip_tempfile).to have_received(:close)
      expect(File).to have_received(:unlink).with('/tmp/csv_file.csv')
      expect(File).to have_received(:unlink).with('/tmp/zip_file.zip')
    end

    describe 'tempfile cleanup edge cases' do
      it 'handles missing tempfiles gracefully' do
        allow(Moves::Exporter).to receive(:new).and_return(instance_double(Moves::Exporter, call: nil))

        expect { worker.perform(recipient_email, move_ids) }.not_to raise_error
      end

      it 'handles file deletion errors gracefully' do
        allow(File).to receive(:unlink).and_raise(Errno::ENOENT, 'File not found')

        expect(Rails.logger).to receive(:warn).twice
        expect { worker.perform(recipient_email, move_ids) }.not_to raise_error
      end
    end
  end
end
