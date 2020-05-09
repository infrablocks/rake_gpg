require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Encryption
      class Decrypt < RakeFactory::Task
        default_name :decrypt
        default_description "Decrypt a file using GPG"

        parameter :key_file_path, required: true
        parameter :input_file_path, required: true
        parameter :output_file_path, required: true

        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary

        parameter :trust_mode, default: :always
        parameter :passphrase

        action do |t|
          mkdir_p(t.work_directory)

          puts "Decrypting #{t.input_file_path} with key #{t.key_file_path}..."
          Home.new(t.work_directory, t.home_directory)
              .with_resolved_directory do |home_directory|
            RubyGPG2.import(
                key_file_paths: [t.key_file_path],
                work_directory: t.work_directory,
                home_directory: home_directory)

            mkdir_p(File.dirname(t.output_file_path))

            RubyGPG2.decrypt(
                input_file_path: t.input_file_path,
                output_file_path: t.output_file_path,
                home_directory: home_directory,
                trust_mode: t.trust_mode,
                passphrase: t.passphrase,
                pinentry_mode: t.passphrase ? :loopback : nil,
                without_passphrase: !t.passphrase)
          end
          puts "Done."
        end
      end
    end
  end
end
