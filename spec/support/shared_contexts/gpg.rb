# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
shared_context 'gpg' do
  def generate_key(work_directory, home_directory, parameters = {})
    lookup_key_fingerprint(
      with_parameter_file(
        default_key_parameters.merge(parameters), work_directory
      ) do |parameter_file|
        generate_key_without_passphrase(
          work_directory, home_directory, parameter_file.path
        )
      end
    )
  end

  def export_public_key(
    work_directory,
    home_directory,
    output_path,
    key_fingerprint
  )
    RubyGPG2.export(
      names: [key_fingerprint],
      output_file_path:
          "#{work_directory}/#{output_path}",
      armor: true,
      home_directory: home_directory
    )
  end

  def export_secret_key(
    work_directory,
    home_directory,
    output_path,
    key_fingerprint,
    options = {}
  )
    RubyGPG2.export_secret_keys(
      names: [key_fingerprint],
      output_file_path:
          "#{work_directory}/#{output_path}",
      armor: true,
      pinentry_mode: :loopback,
      passphrase: options[:passphrase],
      home_directory: home_directory
    )
  end

  def import_key_from_path(work_directory, home_directory, key_file_path)
    RubyGPG2.import(
      key_file_paths: [key_file_path],
      work_directory: work_directory,
      home_directory: home_directory
    )
  end

  def encrypt(
    home_directory, key_fingerprint, input_file_path, output_file_path
  )
    RubyGPG2.encrypt(
      recipient: key_fingerprint,
      input_file_path: input_file_path,
      output_file_path: output_file_path,
      home_directory: home_directory,
      armor: true,
      trust_mode: :always
    )
  end

  def decrypt(home_directory, input_file_path, output_file_path)
    RubyGPG2.decrypt(
      input_file_path: input_file_path,
      output_file_path: output_file_path,
      home_directory: home_directory
    )
  end

  private

  def with_parameter_file(parameters, work_directory, &block)
    RubyGPG2::ParameterFileContents
      .new(parameters)
      .in_temp_file(work_directory) do |f|
      block.call(f)
    end
  end

  def default_key_parameters
    {
      key_type: 'RSA',
      key_length: 2048,
      subkey_type: 'RSA',
      subkey_length: 2048,
      owner_name: 'Amanda Greeves',
      owner_email: 'amanda.greeves@example.com',
      expiry: :never
    }
  end

  def generate_key_without_passphrase(
    work_directory, home_directory, parameter_file_path
  )
    RubyGPG2.generate_key(
      parameter_file_path: parameter_file_path,
      home_directory: home_directory,
      work_directory: work_directory,
      without_passphrase: true,
      with_status: true
    )
  end

  def lookup_key_fingerprint(result)
    result.status
          .filter_by_type(:key_created)
          .first_line
          .key_fingerprint
  end
end
# rubocop:enable RSpec/ContextWording
