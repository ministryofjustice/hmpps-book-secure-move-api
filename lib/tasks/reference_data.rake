# frozen_string_literal: true

namespace :reference_data do
  desc 'create ethnicities'
  task create_ethnicities: :environment do
    NomisClient::Ethnicities.get.each do |ethnicity|
      next if ethnicity['activeFlag'] == 'N'

      Ethnicity
        .create_with(title: ethnicity['description'])
        .find_or_create_by(key: ethnicity['code'])
    end
  end

  desc 'create genders'
  task create_genders: :environment do
    NomisClient::Genders.get.each do |gender|
      next if gender['activeFlag'] == 'N'

      Gender
        .create_with(title: gender['description'])
        .find_or_create_by(key: gender['code'])
    end
  end
end
