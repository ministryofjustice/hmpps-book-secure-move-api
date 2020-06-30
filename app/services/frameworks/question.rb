module Frameworks
  class Question
    attr_reader :source, :questions, :filepath

    def initialize(filepath:, questions:)
      @filepath = filepath
      @source = YAML.safe_load(File.read(filepath))
      @questions = questions
    end

    def key
      @key ||= File.basename(filepath, '.yml')
    end

    def call
      question.question_type = source['type']
      question.required = true if required?(source['validations'])
      build_options(source.fetch('options', []))

      questions
    end

    def required?(validations)
      validation_types = validations.flat_map { |validation| validation['type'] }
      validation_types.any?('required')
    end

    def build_options(options)
      options.each do |option|
        question.options << option['value']

        build_followup_questions(
          followups: option.fetch('followup', []),
          value: option['value'],
        )

        build_followup_comments(
          followup_comment: option['followup_comment'],
          value: option['value'],
        )

        build_flags(flags: option.fetch('flags', []), value: option['value'])
      end
    end

    def build_followup_comments(followup_comment:, value:)
      if followup_comment
        question.followup_comment = true
        question.followup_comment_options << value if required?(followup_comment.fetch('validations', []))
      end
    end

    def build_followup_questions(followups:, value:)
      followups.each do |followup|
        questions[followup] = questions[followup] || FrameworkQuestion.new(key: followup)
        questions[followup].section = question.section
        questions[followup].dependent_value = value
        questions[followup].parent = question
      end
    end

    def build_flags(flags:, value:)
      flags.each do |flag|
        question.flags.new(
          flag_type: flag['type'],
          name: flag['label'],
          question_value: value,
        )
      end
    end

    def question
      @question ||= begin
        questions[key] = questions[key] || FrameworkQuestion.new(key: key)
      end
    end
  end
end
