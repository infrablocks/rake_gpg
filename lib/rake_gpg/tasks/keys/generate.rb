# frozen_string_literal: true

require 'rake_factory'
require 'ruby_gpg2'

require_relative '../../home'

module RakeGPG
  module Tasks
    module Keys
      # rubocop:disable Metrics/ClassLength
      class Generate < RakeFactory::Task
        default_name :generate
        default_description 'Generate a GPG key'

        parameter :name_prefix, default: 'gpg'
        parameter :armor, default: true

        parameter :work_directory, default: '/tmp'
        parameter :home_directory, default: :temporary
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

        action do
          make_work_directory
          log_generating_key
          in_home_directory do |home_directory|
            result = generate_key(home_directory)
            key_fingerprint = lookup_key_fingerprint(result)
            log_generated_key(key_fingerprint)
            maybe_export_key(home_directory, key_fingerprint)
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
          mkdir_p(output_directory)
        end

        def lookup_key_fingerprint(result)
          result.status.filter_by_type(:key_created)
                .first_line.key_fingerprint
        end

        # rubocop:disable Metrics/MethodLength
        def generate_key(home_directory)
          RubyGPG2::ParameterFileContents
            .new(parameter_values)
            .in_temp_file(work_directory) do |f|
            RubyGPG2.generate_key(
              parameter_file_path: f.path,
              home_directory: home_directory,
              work_directory: work_directory,
              without_passphrase: passphrase.nil?,
              with_status: true
            )
          end
        end
        # rubocop:enable Metrics/MethodLength

        def maybe_export_key(home_directory, key_fingerprint)
          return unless output_directory

          log_exporting_key
          make_output_directory
          export_public_key(home_directory, key_fingerprint)
          export_private_key(home_directory, key_fingerprint)
        end

        def export_public_key(home_directory, key_fingerprint)
          RubyGPG2.export(
            names: [key_fingerprint],
            output_file_path: "#{output_directory}/#{name_prefix}.public",
            armor: armor,
            home_directory: home_directory
          )
        end

        def export_private_key(home_directory, key_fingerprint)
          RubyGPG2.export_secret_keys(
            names: [key_fingerprint],
            output_file_path: "#{output_directory}/#{name_prefix}.private",
            armor: armor,
            passphrase: passphrase,
            pinentry_mode: passphrase.nil? ? nil : :loopback,
            home_directory: home_directory
          )
        end

        def log_generating_key
          $stdout.puts(
            "Generating GPG key for #{owner_name} <#{owner_email}>..."
          )
        end

        def log_generated_key(key_fingerprint)
          $stdout.puts(
            "Generated GPG key with fingerprint #{key_fingerprint}."
          )
        end

        def log_exporting_key
          $stdout.puts(
            'Export requested. Exporting GPG key to ' \
            "#{output_directory}..."
          )
        end

        def log_done
          $stdout.puts('Done.')
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
