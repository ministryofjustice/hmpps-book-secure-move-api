# frozen_string_literal: true

module PersonalCareNeeds
  class Importer
    ASSESSMENT_ANSWER_CATEGORY = 'health'

    QUESTION_KEY_PREGNANT = 'pregnant'
    QUESTION_KEY_SPECIAL_VEHICLE = 'special_vehicle'
    QUESTION_KEY_FALLBACK = 'pregnant'

    DOMAIN_PHYSICAL = 'PHY'
    DOMAIN_DISABILITY = 'DISAB'
    DOMAIN_MATERNITY = 'MATSTAT'
    DOMAIN_UNKNOWN = nil

    DOMAIN_TO_NOMIS_ALERT_TYPE_DESCRIPTION = {
      DOMAIN_PHYSICAL   => 'Medical',
      DOMAIN_DISABILITY => 'Disability',
      DOMAIN_MATERNITY  => 'Maternity Status',
    }.freeze
    DEFAULT_ALERT_TYPE_DESCRIPTION = 'Unknown'

    PROBLEM_CODE_TO_QUESTION_KEY_AND_DOMAIN_MAPPING = {
      'DI'     => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_FALLBACK        }, # Diabetic,Medical
      'BRK'    => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Broken Bone/s,Medical
      'SPR'    => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Sprain,Medical
      'TOT'    => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_FALLBACK        }, # Dental,Medical
      'ARTH'   => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Arthritic,Medical
      'ASTH'   => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_FALLBACK        }, # Asthmatic,Medical
      'AUTI'   => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_FALLBACK        }, # Autism,Medical
      'EPI'    => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Epileptic,Medical
      'FALS'   => { domain: DOMAIN_PHYSICAL,   question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # False Limbs,Medical
      'DEP'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Depression,Psychological
      'BIP'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Bi-Polar,Psychological
      'HDL'    => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Deaf - Lip Reads,Disability
      'HDS'    => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Deaf - Uses Sign Language,Disability
      'HD'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Hearing Impairment - not deaf,Disability
      'SI'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Speech Impediment,Disability
      'VI'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Visual Impairment (Inc. Blind),Disability
      'RM'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Reduced Mobility,Disability
      'PC'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Progressive Condition,Disability
      'RC'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Reduced Physical Capacity,Disability
      'SD'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Severe Disfigurement,Disability
      'MI'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Mental Illness,Disability
      'LD'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Learning Difficulties (Inc. Dyslexia),Disability
      'LDY'    => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Learning Difficulties (Inc. Autism),Disability
      'OD'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_SPECIAL_VEHICLE }, # Other Disability,Disability
      'NR'     => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # No Disability Recorded,Disability
      'PRD'    => { domain: DOMAIN_DISABILITY, question_key: QUESTION_KEY_FALLBACK        }, # Refused to Disclose,Disability
      'PREG'   => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # Pregnant Unaccompanied,Maternity Status
      'NO9U18' => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Not Preg, acc over 9mths under 18mths",Maternity Status
      'NU9'    => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Not Preg, acc under 9mths",Maternity Status
      'NU9U18' => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Not Preg, acc under 9mths under 18mths",Maternity Status
      'ACCU18' => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Preg, acc over 9mths under 18mths",Maternity Status
      'ACCU9'  => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Preg, acc under 9mths",Maternity Status
      'AU9U18' => { domain: DOMAIN_MATERNITY,  question_key: QUESTION_KEY_PREGNANT        }, # "Preg, acc under 9mths under 18mths",Maternity Status
      'NED'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Nutrition Eating and Drinking,Social Care
      'PH'     => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Personal Hygiene,Social Care
      'TTG'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Toileting,Social Care
      'BAC'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Being Appropriately Clothed,Social Care
      'UPS'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Using Prison Safely,Social Care
      'CHS'    => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Maintaining Cell To Habitable Standard,Social Care
      'MR'     => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Maintaining Relationships,Social Care
      'AA'     => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Accessing Activities,Social Care
      'AS'     => { domain: DOMAIN_UNKNOWN,    question_key: QUESTION_KEY_FALLBACK        }, # Accessing Services,Social Care
    }.freeze
    DEFAULT_PROBLEM_CODE_MAPPING = { domain: DOMAIN_UNKNOWN, question_key: QUESTION_KEY_FALLBACK }.freeze

    def initialize(profile:, personal_care_needs:)
      @profile = profile
      @personal_care_needs = personal_care_needs
    end

    def call
      assessment_answers = personal_care_needs.map do |personal_care_need|
        mapping = PROBLEM_CODE_TO_QUESTION_KEY_AND_DOMAIN_MAPPING.fetch(
          personal_care_need[:problem_code], DEFAULT_PROBLEM_CODE_MAPPING
        )

        description = DOMAIN_TO_NOMIS_ALERT_TYPE_DESCRIPTION.fetch(
          mapping[:domain], DEFAULT_ALERT_TYPE_DESCRIPTION
        )
        question = AssessmentQuestion.find_by(key: mapping[:question_key])

        Profile::AssessmentAnswer.from_nomis_personal_care_need(personal_care_need, question, description)
      end

      profile.merge_assessment_answers!(assessment_answers, ASSESSMENT_ANSWER_CATEGORY)
    end

  private

    attr_reader :profile, :personal_care_needs
  end
end
