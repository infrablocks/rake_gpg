# frozen_string_literal: true

require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Keys
      class Import < RakeFactory::Task
        default_name :import
        default_description 'Import a GPG key'

        parameter :key_file_path, required: true
        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary

        action do
          make_work_directory
          log_importing_key
          in_home_directory do |home_directory|
            import(home_directory)
          end
          log_done
        end

        private

        def in_home_directory(&block)
          Home.new(work_directory, home_directory)
              .with_resolved_directory do |home_directory|
            block.call(home_directory)
          end
        end

        def make_work_directory
          mkdir_p(work_directory)
        end

        def import(home_directory)
          RubyGPG2.import(
            key_file_paths: [key_file_path],
            home_directory: home_directory
          )
        end

        def log_importing_key
          $stdout.puts(
            "Importing GPG key from #{key_file_path} into #{home_directory}..."
          )
        end

        def log_done
          $stdout.puts 'Done.'
        end
      end
    end
  end
end
