require 'rake_factory'
require 'ruby_gpg2'

module RakeGPG
  module Tasks
    module Encryption
      class Encrypt < RakeFactory::Task
        default_name :encrypt
        default_description "Encrypt a file using GPG"

        parameter :key_file_path, required: true
        parameter :input_file_path, required: true
        parameter :output_file_path, required: true

        parameter :work_directory, default: 'build/gpg'
        parameter :home_directory, default: :temporary

        parameter :armor, default: true
        parameter :trust_mode, default: :always

        action do |t|
          if t.home_directory == :temporary
            Dir.mktmpdir(
                'home', t.work_directory) do |home_directory|
              do_encrypt(t, home_directory)
            end
          else
            do_encrypt(t, t.home_directory)
          end
        end

        private

        def do_encrypt(t, home_directory)
          puts "Encrypting #{t.input_file_path} for key #{t.key_file_path}..."
          result = RubyGPG2.import(
              key_file_paths: [t.key_file_path],
              work_directory: t.work_directory,
              home_directory: home_directory,
              with_status: true)

          key_fingerprint = result
              .status
              .filter_by_type(:import_ok)
              .first_line
              .key_fingerprint

          RubyGPG2.encrypt(
              recipient: key_fingerprint,
              input_file_path: t.input_file_path,
              output_file_path: t.output_file_path,
              home_directory: home_directory,
              armor: t.armor,
              trust_mode: t.trust_mode)
          puts "Done."
        end
      end
    end
  end
end
