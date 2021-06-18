GITHUB_FRAMEWORK_URI = 'https://github.com/ministryofjustice/hmpps-book-secure-move-frameworks.git'.freeze
GITHUB_FRAMEWORK_NAME = 'hmpps-book-secure-move-frameworks'.freeze
FRAMEWORK_TEMP_PATH = Rails.root.join('tmp/checkout').freeze

namespace :frameworks do
  desc 'Populate versioned questions from frameworks repository'
  task :populate_data, %i[filepath version] => :environment do |_, args|
    if (filepath = args[:filepath]).present? && (version = args[:version]).present?
      print("Populating Framework from filepath: #{filepath} and version: #{version}\n")

      import_framework(filepath, version)
    elsif args[:filepath].blank? && args[:version].blank?
      print("Populating Frameworks from Github tags\n")
      begin
        respository = Git.clone(GITHUB_FRAMEWORK_URI, GITHUB_FRAMEWORK_NAME, path: FRAMEWORK_TEMP_PATH)
        respository.tags.each do |tag|
          respository.checkout(tag.name)
          version = tag.name.gsub('v', '')
          filepath = "#{respository.dir.path}/frameworks"
          import_framework(filepath, version)
        end
      ensure
        FileUtils.rm_rf(FRAMEWORK_TEMP_PATH)
      end
    else
      abort('Either provide both a filepath and version, or neither to default to Github tags')
    end
  end
end

def import_framework(filepath, version)
  framework_importer = Frameworks::Importer.new(filepath: filepath, version: version)
  framework_importer.call

  print("Errors: #{framework_importer.errors}\n") if framework_importer.errors.any?
end
