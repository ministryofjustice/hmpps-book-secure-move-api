namespace :frameworks do
  desc 'Populate versioned questions from frameworks repository'
  task :populate_data, %i[filepath version] => :environment do |_, args|
    unless (filepath = args[:filepath]).present? && (version = args[:version]).present?
      abort('No filepath or version provided')
    end

    Frameworks::Importer.new(filepath: filepath, version: version).call
  end
end
