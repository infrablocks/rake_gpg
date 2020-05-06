shared_context :gpg do
  def generate_key(work_directory, home_directory, parameters = {})
    parameters = {
        key_type: 'RSA',
        key_length: 2048,
        subkey_type: 'RSA',
        subkey_length: 2048,
        owner_name: 'Amanda Greeves',
        owner_email: 'amanda.greeves@example.com',
        expiry: :never
    }.merge(parameters)
    RubyGPG2::ParameterFileContents
        .new(parameters)
        .in_temp_file(work_directory) { |f|
          RubyGPG2.generate_key(
              parameter_file_path: f.path,
              home_directory: home_directory,
              work_directory: work_directory,
              without_passphrase: true,
              with_status: true)
        }
        .status
        .filter_by_type(:key_created)
        .first_line
        .key_fingerprint
  end

  def export_public_key(
      work_directory,
      home_directory,
      output_path,
      key_fingerprint)
    RubyGPG2.export(
        names: [key_fingerprint],
        output_file_path:
            "#{work_directory}/#{output_path}",
        armor: true,
        home_directory: home_directory)
  end

  def export_secret_key(
      work_directory,
      home_directory,
      output_path,
      key_fingerprint,
      options = {})
    RubyGPG2.export_secret_keys(
        names: [key_fingerprint],
        output_file_path:
            "#{work_directory}/#{output_path}",
        armor: true,
        pinentry_mode: :loopback,
        passphrase: options[:passphrase],
        home_directory: home_directory)
  end

  def import_key(work_directory, home_directory, key_file_path)
    RubyGPG2.import(
        key_file_paths: [key_file_path],
        work_directory: work_directory,
        home_directory: home_directory)
  end
end