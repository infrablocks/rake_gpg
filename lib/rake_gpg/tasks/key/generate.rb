require 'rake_factory'
require 'ruby_gpg2'

module RakeGPG
  module Tasks
    module Key
      class Generate < RakeFactory::Task
        default_name :generate
        default_description "Generate a GPG key"

        parameter :path, required: true
        parameter :name_prefix, default: 'gpg'

        parameter :work_directory, default: 'build/gpg'

        parameter :key_type, default: 'RSA'
        parameter :key_length, default: 2048
        parameter :subkey_type, default: 'RSA'
        parameter :subkey_length, default: 2048

        parameter :owner_name, required: true
        parameter :owner_email, required: true
        parameter :owner_comment

        parameter :expiry, default: :never
        parameter :passphrase

        action do |t|
          puts "Generating GPG key for #{owner_name} <#{owner_email}>..."
          mkdir_p t.work_directory
          result = RubyGPG2::ParameterFileContents
              .new(t.parameter_values)
              .in_temp_file(t.work_directory) do |f|
            RubyGPG2.generate_key(
                parameter_file_path: f.path,
                home_directory: t.work_directory,
                without_passphrase: t.passphrase.nil?,
                with_status: true)
          end
          key_fingerprint = result
              .status
              .filter_by_type(:key_created)
              .first_line
              .key_fingerprint
          mkdir_p t.path
          RubyGPG2.export(
              names: [key_fingerprint],
              output_file_path: "#{t.path}/#{t.name_prefix}.public",
              armor: true,
              home_directory: t.work_directory)
          RubyGPG2.export_secret_keys(
              names: [key_fingerprint],
              output_file_path: "#{t.path}/#{t.name_prefix}.private",
              armor: true,
              home_directory: t.work_directory)
        end
      end
    end
  end
end
