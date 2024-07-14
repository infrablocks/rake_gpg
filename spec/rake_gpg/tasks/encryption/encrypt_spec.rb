# frozen_string_literal: true

require 'spec_helper'
require 'ruby_gpg2'

describe RakeGPG::Tasks::Encryption::Encrypt do
  include_context 'rake'
  include_context 'gpg'

  before do
    stub_output
  end

  after do
    RubyGPG2.reset!
  end

  def define_task(opts = {}, &)
    opts = { namespace: :encryption }.merge(opts)

    namespace opts[:namespace] do
      described_class.define(opts, &)
    end
  end

  it 'adds an encrypt task in the namespace in which it is created' do
    define_task(
      key_file_path: 'some/gpg/key',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    expect(Rake.application)
      .to(have_task_defined('encryption:encrypt'))
  end

  it 'gives the encrypt task a description' do
    define_task(
      key_file_path: 'some/gpg/key',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    expect(Rake::Task['encryption:encrypt'].full_comment)
      .to(eq('Encrypt a file using GPG'))
  end

  it 'fails if no key file path is provided' do
    define_task(
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    expect do
      Rake::Task['encryption:encrypt'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no input file path is provided' do
    define_task(
      key_file_path: 'some/gpg/key',
      output_file_path: 'some/output/file'
    )

    expect do
      Rake::Task['encryption:encrypt'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no output file path is provided' do
    define_task(
      key_file_path: 'some/gpg/key',
      input_file_path: 'some/file/to/encrypt'
    )

    expect do
      Rake::Task['encryption:encrypt'].invoke
    end.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'uses a work directory of /tmp by default' do
    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq('/tmp'))
  end

  it 'uses the provided work directory when specified' do
    work_directory = 'some/work/directory'

    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file',
      work_directory:
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq(work_directory))
  end

  it 'uses a home directory of :temporary by default' do
    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(:temporary))
  end

  it 'uses the provided home directory when specified' do
    home_directory = 'some/home/directory'

    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file',
      home_directory:
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(home_directory))
  end

  it 'uses armor by default' do
    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.armor).to(be(true))
  end

  it 'uses the provided value for armor when specified' do
    armor = false

    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file',
      armor:
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.armor).to(be(false))
  end

  it 'uses a trust mode of always by default' do
    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file'
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.trust_mode).to(be(:always))
  end

  it 'uses the provided value for trust mode when specified' do
    trust_mode = :classic

    define_task(
      key_file_path: 'some/key/path',
      input_file_path: 'some/file/to/encrypt',
      output_file_path: 'some/output/file',
      trust_mode:
    )

    rake_task = Rake::Task['encryption:encrypt']
    test_task = rake_task.creator

    expect(test_task.trust_mode).to(be(:classic))
  end

  it 'encrypts a file for the provided key' do
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"
      public_key_name = 'gpg.public'
      secret_key_name = 'gpg.private'

      public_key_file_path = "#{temp_directory}/#{public_key_name}"
      secret_key_file_path = "#{temp_directory}/#{secret_key_name}"

      input_file_path = "#{temp_directory}/some-file.plain"
      encrypted_file_path = "#{temp_directory}/some-file.encrypted"
      decrypted_file_path = "#{temp_directory}/some-file.decrypted"

      File.write(input_file_path, 'Hello world')

      Dir.mktmpdir do |generate_home_directory|
        key_fingerprint = generate_key(
          temp_directory, generate_home_directory
        )
        export_public_key(
          temp_directory, generate_home_directory,
          public_key_name, key_fingerprint
        )
        export_secret_key(
          temp_directory, generate_home_directory,
          secret_key_name, key_fingerprint
        )
      end

      define_task(
        key_file_path: public_key_file_path,
        input_file_path:,
        output_file_path: encrypted_file_path,
        work_directory:
      )

      Rake::Task['encryption:encrypt'].invoke

      Dir.mktmpdir do |decrypt_home_directory|
        import_key_from_path(
          temp_directory, decrypt_home_directory, secret_key_file_path
        )
        decrypt(
          decrypt_home_directory, encrypted_file_path, decrypted_file_path
        )

        expect(File.read(decrypted_file_path)).to(eq('Hello world'))
      end
    end
  end

  it 'uses the provided home directory when supplied' do # rubocop:disable RSpec/ExampleLength
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"
      home_directory = "#{temp_directory}/home"

      public_key_name = 'gpg.public'
      secret_key_name = 'gpg.private'

      public_key_file_path = "#{temp_directory}/#{public_key_name}"
      secret_key_file_path = "#{temp_directory}/#{secret_key_name}"

      input_file_path = "#{temp_directory}/some-file.plain"
      encrypted_file_path = "#{temp_directory}/some-file.encrypted"
      decrypted_file_path = "#{temp_directory}/some-file.decrypted"

      File.write(input_file_path, 'Hello world')

      Dir.mktmpdir do |generate_home_directory|
        key_fingerprint = generate_key(temp_directory,
                                       generate_home_directory)
        export_public_key(
          temp_directory, generate_home_directory,
          public_key_name, key_fingerprint
        )
        export_secret_key(
          temp_directory, generate_home_directory,
          secret_key_name, key_fingerprint
        )
      end

      define_task(
        key_file_path: public_key_file_path,
        input_file_path:,
        output_file_path: encrypted_file_path,
        work_directory:,
        home_directory:
      )

      Rake::Task['encryption:encrypt'].invoke

      Dir.mktmpdir do |decrypt_home_directory|
        import_key_from_path(
          temp_directory, decrypt_home_directory, secret_key_file_path
        )
        decrypt(
          decrypt_home_directory, encrypted_file_path, decrypted_file_path
        )

        expect(File.read(decrypted_file_path)).to(eq('Hello world'))
      end
    end
  end

  it 'creates the output directory before attempting to encrypt the file' do
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"

      public_key_name = 'gpg.public'
      secret_key_name = 'gpg.private'

      public_key_file_path = "#{temp_directory}/#{public_key_name}"
      secret_key_file_path = "#{temp_directory}/#{secret_key_name}"

      input_file_path = "#{temp_directory}/some-file.plain"
      encrypted_file_path = "#{temp_directory}/some/nested/file.encrypted"
      decrypted_file_path = "#{temp_directory}/some-file.decrypted"

      File.write(input_file_path, 'Hello world')

      Dir.mktmpdir do |generate_home_directory|
        key_fingerprint = generate_key(
          temp_directory, generate_home_directory
        )
        export_public_key(
          temp_directory, generate_home_directory,
          public_key_name, key_fingerprint
        )
        export_secret_key(
          temp_directory, generate_home_directory,
          secret_key_name, key_fingerprint
        )
      end

      define_task(
        key_file_path: public_key_file_path,
        input_file_path:,
        output_file_path: encrypted_file_path,
        work_directory:
      )

      Rake::Task['encryption:encrypt'].invoke

      Dir.mktmpdir do |decrypt_home_directory|
        import_key_from_path(
          temp_directory, decrypt_home_directory, secret_key_file_path
        )
        decrypt(
          decrypt_home_directory, encrypted_file_path, decrypted_file_path
        )

        expect(File.read(decrypted_file_path)).to(eq('Hello world'))
      end
    end
  end

  def stub_output
    RubyGPG2.configure do |c|
      c.stderr = Tempfile.new
      c.stdout = Tempfile.new
    end
    %i[print puts].each do |method|
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end
end
