# frozen_string_literal: true

namespace :reference_data do
  desc 'create ethnicities'
  task create_ethnicities: :environment do
    Ethnicity.destroy_all
    ethnicities = NomisClient.get(
      '/reference-domains/domains/ETHNICITY',
      headers: { 'Page-Limit' => '100' }
    ).parsed
    ethnicities.each do |ethnicity|
      next if ethnicity['activeFlag'] == 'N'

      Ethnicity.create!(
        key: ethnicity['code'],
        title: ethnicity['description']
      )
    end
  end

  desc 'create genders'
  task create_genders: :environment do
    Gender.destroy_all
    genders = NomisClient.get(
      '/reference-domains/domains/SEX',
      headers: { 'Page-Limit' => '100' }
    ).parsed
    genders.each do |gender|
      next if gender['activeFlag'] == 'N'

      Gender.create!(
        key: gender['code'],
        title: gender['description']
      )
    end
  end
end
