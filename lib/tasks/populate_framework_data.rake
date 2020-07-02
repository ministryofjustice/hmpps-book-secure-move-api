namespace :frameworks do
  desc 'Populate versioned questions from frameworks repository'
  task :populate_data, %i[filepath version] => :environment do |_, args|
    unless (filepath = args[:filepath]).present? && (version = args[:version]).present?
      abort('No filepath or version provided')
    end

    framework_importer = Frameworks::Importer.new(filepath: filepath, version: version)
    framework_importer.call

    print("Errors: #{framework_importer.errors}\n") if framework_importer.errors.any?
  end
end
