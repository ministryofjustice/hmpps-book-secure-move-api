module Frameworks
  class Importer
    attr_reader :filepath, :version

    def initialize(filepath:, version:)
      @filepath = filepath
      @version = version
    end

    def call
      return unless filepath.present? && version.present?

      ActiveRecord::Base.transaction do
        Dir.glob("#{filepath}/**") do |framework|
          if File.directory?(framework)
            questions = {}
            build_manifests(framework, questions)
            build_questions(framework, questions)

            basename = File.basename(framework)
            Framework.create!(name: basename, version: version, framework_questions: questions.values)
          end
        end
      end
    end

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
  end
end
