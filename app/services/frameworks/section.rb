module Frameworks
  class Section
    attr_reader :source, :questions, :filepath, :dependencies

    def initialize(filepath:)
      @filepath = filepath
      @source = YAML.safe_load(File.read(filepath))
      @questions = {}
      @dependencies = {}
    end

    def call
      build_steps

      questions
    end

  private

    def name
      @name ||= File.basename(filepath, '.yml')
    end

    def build_steps
      source.fetch('steps', []).each do |step|
        build_questions(step_questions: step.fetch('questions', []), step_name: step['slug'])
        build_dependencies(step.fetch('next_step', []))
      end
    end

    def build_questions(step_questions:, step_name:)
      step_questions.each do |step_question|
        questions[step_question] = FrameworkQuestion.new(key: step_question, section: name)

        if dependencies[step_name]
          questions[step_question].dependent_value = dependencies[step_name][:value]
          questions[step_question].parent = dependencies[step_name][:parent]
        end
      end
    end

    def build_dependencies(next_steps)
      next_steps.each do |next_step|
        category = next_step['next_step']
        dependencies[category] = { value: next_step['value'], parent: questions[next_step['question']] }
      end
    end
  end
end
