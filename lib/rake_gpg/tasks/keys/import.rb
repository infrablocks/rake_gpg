require 'rake_factory'
require 'ruby_gpg2'

module RakeGPG
  module Tasks
    module Keys
      class Import < RakeFactory::Task
        default_name :import
        default_description "Import a GPG key"

        parameter :key_file_path, required: true
        parameter :work_directory, default: 'build/gpg'
        parameter :home_directory, default: :temporary

        action do |t|
          mkdir_p(t.work_directory)
          if t.home_directory == :temporary
            Dir.mktmpdir(
                'home', t.work_directory) do |home_directory|
              do_import_key(t, home_directory)
            end
          else
            do_import_key(t, t.home_directory)
          end

        end

        private

        def do_import_key(t, home_directory)
          puts "Importing GPG key from #{t.key_file_path} " +
              "into #{home_directory}..."
          RubyGPG2.import(
              key_file_paths: [t.key_file_path],
              home_directory: home_directory)
          puts "Done."
        end
      end
    end
  end
end
