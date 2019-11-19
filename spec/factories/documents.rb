# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    association(:move)
    description { 'some details about the document' }
    document_type { 'ID' }
    file do
      Rack::Test::UploadedFile.new(
        File.join(Rails.root, 'spec/fixtures', 'file-sample_100kB.doc'),
        'application/msword'
      )
    end
  end
end
