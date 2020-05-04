require 'rake_factory'
require 'ruby_gpg2'

module RakeGPG
  module Tasks
    module Key
      class Generate < RakeFactory::Task
        default_name :generate
        default_description "Generate a GPG key"

        parameter :name_prefix, default: 'gpg'
        parameter :armor, default: true

        parameter :work_directory, default: 'build/gpg'
        parameter :home_directory
        parameter :output_directory

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
          mkdir_p t.home_directory if t.home_directory
          mkdir_p t.output_directory if t.output_directory

          result = RubyGPG2::ParameterFileContents
              .new(t.parameter_values)
              .in_temp_file(t.work_directory) do |f|
            RubyGPG2.generate_key(
                parameter_file_path: f.path,
                home_directory: t.home_directory,
                work_directory: t.work_directory,
                without_passphrase: t.passphrase.nil?,
                with_status: true)
          end

          key_fingerprint = result
              .status
              .filter_by_type(:key_created)
              .first_line
              .key_fingerprint

          puts "Generated GPG key with fingerprint #{key_fingerprint}."

          if t.output_directory
            puts 'Export requested. ' +
                "Exporting GPG key to #{t.output_directory}..."
            RubyGPG2.export(
                names: [key_fingerprint],
                output_file_path:
                    "#{t.output_directory}/#{t.name_prefix}.public",
                armor: t.armor,
                home_directory: t.home_directory)
            RubyGPG2.export_secret_keys(
                names: [key_fingerprint],
                output_file_path:
                    "#{t.output_directory}/#{t.name_prefix}.private",
                armor: t.armor,
                home_directory: t.home_directory)
          end

          puts "Done."
        end
      end
    end
  end
end
