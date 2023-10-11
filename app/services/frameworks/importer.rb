module Frameworks
  class Importer
    attr_reader :filepath, :version, :errors

    def initialize(filepath:, version:)
      @filepath = filepath
      @version = version
      @errors = []
    end

    def call
      return unless filepath.present? && version.present?

      ActiveRecord::Base.transaction do
        Dir.glob("#{filepath}/**") do |framework|
          basename = File.basename(framework)

          next unless File.directory?(framework) && Framework.find_by(name: basename, version:).blank?

          questions = {}

          build_manifests(framework, questions)
          build_questions(framework, questions)
          persist_framework(basename, questions)
        end
      end
    end

  private

    def build_manifests(framework, questions)
      Dir.glob("#{framework}/manifests/*.yml") do |manifest|
        questions.merge!(Frameworks::Manifest.new(filepath: manifest).call)
      end
    end

    def build_questions(framework, questions)
      Dir.glob("#{framework}/questions/*.yml") do |question|
        questions.merge!(Frameworks::Question.new(filepath: question, questions: questions.dup).call)
      end
    end

    def persist_framework(name, questions)
      framework = Framework.new(name:, version:, framework_questions: questions.values)

      if framework.save
        return log("Successfully persisted Framework: '#{name}' with version: '#{version}'\n")
      end

      log_errors_for(framework)
    end

    def log(message)
      print(message) unless Rails.env.test? # rubocop:disable Rails/Output
    end

    def log_errors_for(framework)
      log("Failed to persist Framework: '#{framework.name}' with version: '#{version}'\n")

      add_errors(framework.name, framework)
      framework.framework_questions.each { |question| add_errors(question.key, question) }
    end

    def add_errors(name, object)
      errors << "#{name}: #{object.errors.full_messages.join(', ')}" if object.errors.any?
    end
  end
end
