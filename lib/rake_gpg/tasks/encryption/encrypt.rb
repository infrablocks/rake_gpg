# frozen_string_literal: true

require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Encryption
      class Encrypt < RakeFactory::Task
        default_name :encrypt
        default_description 'Encrypt a file using GPG'

        parameter :key_file_path, required: true
        parameter :input_file_path, required: true
        parameter :output_file_path, required: true

        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary

        parameter :armor, default: true
        parameter :trust_mode, default: :always

        action do
          make_work_directory
          log_encrypting
          in_home_directory do |home_directory|
            result = import_key(home_directory)
            key_fingerprint = lookup_key_fingerprint(result)
            make_output_directory
            encrypt(home_directory, key_fingerprint)
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

        def make_output_directory
          mkdir_p(File.dirname(output_file_path))
        end

        def import_key(home_directory)
          RubyGPG2.import(
            key_file_paths: [key_file_path],
            work_directory: work_directory,
            home_directory: home_directory,
            with_status: true
          )
        end

        def lookup_key_fingerprint(result)
          result.status.filter_by_type(:import_ok)
                .first_line.key_fingerprint
        end

        def encrypt(home_directory, key_fingerprint)
          RubyGPG2.encrypt(
            recipient: key_fingerprint,
            input_file_path: input_file_path,
            output_file_path: output_file_path,
            home_directory: home_directory,
            armor: armor,
            trust_mode: trust_mode
          )
        end

        def log_encrypting
          $stdout.puts(
            "Encrypting #{input_file_path} for key #{key_file_path}..."
          )
        end

        def log_done
          $stdout.puts('Done.')
        end
      end
    end
  end
end
