# frozen_string_literal: true

require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Encryption
      class Decrypt < RakeFactory::Task
        default_name :decrypt
        default_description 'Decrypt a file using GPG'

        parameter :key_file_path, required: true
        parameter :input_file_path, required: true
        parameter :output_file_path, required: true

        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary

        parameter :trust_mode, default: :always
        parameter :passphrase

        action do
          make_work_directory
          log_decrypting
          in_home_directory do |home_directory|
            import_key(home_directory)
            make_output_directory
            decrypt(home_directory)
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

        def import_key(home_directory)
          RubyGPG2.import(
            key_file_paths: [key_file_path],
            work_directory:,
            home_directory:
          )
        end

        def make_work_directory
          mkdir_p(work_directory)
        end

        def make_output_directory
          mkdir_p(File.dirname(output_file_path))
        end

        def decrypt(home_directory)
          RubyGPG2.decrypt(
            input_file_path:,
            output_file_path:,
            home_directory:,
            trust_mode:,
            passphrase:,
            pinentry_mode: passphrase ? :loopback : nil,
            without_passphrase: !passphrase
          )
        end

        def log_decrypting
          $stdout.puts(
            "Decrypting #{input_file_path} with key #{key_file_path}..."
          )
        end

        def log_done
          $stdout.puts('Done.')
        end
      end
    end
  end
end
