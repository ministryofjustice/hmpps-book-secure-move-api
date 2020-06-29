module Frameworks
  class Importer
    attr_reader :filepath, :version, :questions

    def initialize(filepath:, version:)
      @filepath = filepath
      @version = version
      @questions = {}
    end

    def call
      return unless filepath.present? && version.present?

      ActiveRecord::Base.transaction do
        Dir.glob("#{filepath}/**") do |framework|
          if File.directory?(framework)
            build_manifests(framework)
            build_questions(framework)

            basename = File.basename(framework)
            Framework.create!(name: basename, version: version, framework_questions: questions.values)
          end
        end
      end
    end

    def build_manifests(framework)
      Dir.glob("#{framework}/manifests/*.yml") do |manifest|
        questions.merge!(Frameworks::Section.new(filepath: manifest).call)
      end
    end

    def build_questions(framework)
      Dir.glob("#{framework}/questions/*.yml") do |question|
        questions.merge!(Frameworks::Question.new(filepath: question, questions: questions).call)
      end
    end
  end
end
