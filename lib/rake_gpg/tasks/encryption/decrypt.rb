require 'rake_factory'
require 'ruby_gpg2'

module RakeGPG
  module Tasks
    module Encryption
      class Decrypt < RakeFactory::Task
        default_name :decrypt
        default_description "Decrypt a file using GPG"

        parameter :key_file_path, required: true
        parameter :input_file_path, required: true
        parameter :output_file_path, required: true

        parameter :work_directory, default: 'build/gpg'
        parameter :home_directory, default: :temporary

        parameter :trust_mode, default: :always
        parameter :passphrase

        action do |t|
          mkdir_p(t.work_directory)
          if t.home_directory == :temporary
            Dir.mktmpdir(
                'home', t.work_directory) do |home_directory|
              do_decrypt(t, home_directory)
            end
          else
            mkdir_p(t.home_directory)
            do_decrypt(t, t.home_directory)
          end
        end

        private

        def do_decrypt(t, home_directory)
          puts "Decrypting #{t.input_file_path} with key #{t.key_file_path}..."
          RubyGPG2.import(
              key_file_paths: [t.key_file_path],
              work_directory: t.work_directory,
              home_directory: home_directory)

          RubyGPG2.decrypt(
              input_file_path: t.input_file_path,
              output_file_path: t.output_file_path,
              home_directory: home_directory,
              trust_mode: t.trust_mode,
              passphrase: t.passphrase,
              pinentry_mode: t.passphrase ? :loopback : nil,
              without_passphrase: !t.passphrase)
          puts "Done."
        end
      end
    end
  end
end
