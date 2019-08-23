# frozen_string_literal: true

module Nomis
  class Faker
    CHARACTERS = %i[A C E F H J K M N P R T U V W X Y].freeze
    NUMBERS = %i[1 2 3 4 5 6 7 8 9].freeze
    ETHNICITIES = [
      'White: Eng./Welsh/Scot./N.Irish/British',
      'Mixed: White and Black Caribbean',
      'Other: Any other background',
      'White: Any other background',
      'Black/Black British: African',
      'Asian/Asian British: Pakistani',
      'Asian/Asian British: Bangladeshi',
      'Black/Black British: Caribbean',
      'Asian/Asian British: Indian',
      'Black/Black British: Any other Backgr\'nd'
    ].freeze
    BIRTH_COUNTRIES = [
      'England',
      'Viet Nam',
      'Poland',
      'Pakistan',
      'Slovakia (Slovak Republic)',
      'Greece',
      'Morocco',
      'Albania',
      'Hungary',
      'Scotland',
      'Sweden',
      'Australia',
      'Italy',
      'Romania'
    ].freeze
    RELIGIONS = [
      'Church of England (Anglican)',
      'No Religion',
      'Rastafarian',
      'Muslim',
      'Roman Catholic',
      'Christian',
      'Atheist',
      'Buddhist',
      'Pentecostal'
    ].freeze
    CONVICTION_STATUSES = %w[Convicted Remand].freeze
    IMPRISONMENT_STATUSES = %w[SENT03 JR ADIMP_ORA TRL LASPO_DR ALP MLP LIFE LR SEC38 LR_ORA FTR_ORA UNKNOWN].freeze
    MARITAL_STATUSES = [
      'Single-not married/in civil partnership',
      'Married or in civil partnership',
      'Prefer not to say'
    ].freeze

    def self.nomis_offender_number
      CHARACTERS.sample.to_s +
        NUMBERS.sample(4).join +
        CHARACTERS.sample(2).join
    end

    def self.pnc_number
      "#{NUMBERS.sample(2).join}/#{NUMBERS.sample(6).join}#{CHARACTERS.sample}"
    end

    def self.cro_number
      "#{NUMBERS.sample(5).join}/#{NUMBERS.sample(2).join}#{CHARACTERS.sample}"
    end

    def self.ethnicity
      ETHNICITIES.sample
    end

    def self.birth_country
      BIRTH_COUNTRIES.sample
    end

    def self.religion
      RELIGIONS.sample
    end

    def self.conviction_status
      CONVICTION_STATUSES.sample
    end

    def self.imprisonment_status
      IMPRISONMENT_STATUSES.sample
    end

    def self.marital_status
      MARITAL_STATUSES.sample
    end
  end
end
