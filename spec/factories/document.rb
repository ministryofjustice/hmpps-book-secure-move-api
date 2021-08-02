# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec/fixtures/files/file-sample_100kB.doc'),
        'application/msword',
      )
    end
  end
end
