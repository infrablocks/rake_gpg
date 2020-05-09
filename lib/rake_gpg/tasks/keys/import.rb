require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Keys
      class Import < RakeFactory::Task
        default_name :import
        default_description "Import a GPG key"

        parameter :key_file_path, required: true
        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary

        action do |t|
          mkdir_p(t.work_directory)

          puts "Importing GPG key from #{t.key_file_path} " +
              "into #{home_directory}..."
          Home.new(t.work_directory, t.home_directory)
              .with_resolved_directory do |home_directory|
            RubyGPG2.import(
                key_file_paths: [t.key_file_path],
                home_directory: home_directory)
          end
          puts "Done."
        end
      end
    end
  end
end
