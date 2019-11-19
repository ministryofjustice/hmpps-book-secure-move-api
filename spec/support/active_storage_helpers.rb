# frozen_string_literal: true

module ActiveStorageHelpers
  def create_file_blobs(filename:, content_type:, metadata: nil)
    ActiveStorage::Blob.create_after_upload!(
      io: File.join(Rails.root, 'spec/fixtures', filename).open,
      filename: filename,
      content_type: content_type,
      metadata: metadata
    )
  end
end
