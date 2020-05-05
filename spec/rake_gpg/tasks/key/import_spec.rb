require 'spec_helper'
require 'ruby_gpg2'

describe RakeGPG::Tasks::Key::Import do
  include_context :rake

  before(:each) do
    stub_output
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :key}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds an import task in the namespace in which it is created' do
    define_task(
        key_file_path: 'some/key/path')

    expect(Rake::Task.task_defined?('key:import'))
        .to(be(true))
  end

  it 'gives the import task a description' do
    define_task(
        key_file_path: 'some/key/path')

    expect(Rake::Task['key:import'].full_comment)
        .to(eq('Import a GPG key'))
  end

  it 'fails if no key file path is provided' do
    define_task

    expect {
      Rake::Task['key:import'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'uses the provided key file path when specified' do
    key_file_path = 'some/key/path'

    define_task(
        key_file_path: key_file_path)

    rake_task = Rake::Task['key:import']
    test_task = rake_task.creator

    expect(test_task.key_file_path).to(eq(key_file_path))
  end

  it 'uses a work directory of build/gpg by default' do
    define_task(
        key_file_path: 'some/key/path')

    rake_task = Rake::Task['key:import']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq('build/gpg'))
  end

  it 'uses the provided work directory when specified' do
    work_directory = 'some/work/directory'

    define_task(
        key_file_path: 'some/key/path',
        work_directory: work_directory)

    rake_task = Rake::Task['key:import']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq(work_directory))
  end

  it 'uses a home directory of :temporary by default' do
    define_task(
        key_file_path: 'some/key/path')

    rake_task = Rake::Task['key:import']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(:temporary))
  end

  it 'uses the provided home directory when specified' do
    home_directory = 'some/home/directory'

    define_task(
        key_file_path: 'some/key/path',
        home_directory: home_directory)

    rake_task = Rake::Task['key:import']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(home_directory))
  end

  it 'imports the provided GPG key into the keychain' do
    Dir.mktmpdir do |work_directory|
      key_name = 'gpg.public'
      parameters = {
          owner_name: 'Amanda Greeves',
          owner_email: 'amanda.greeves@example.com',
          owner_comment: nil,
          algorithm: :rsa_encrypt_or_sign,
          key_type: 'RSA',
          key_length: 2048,
          subkey_type: 'RSA',
          subkey_length: 2048,
          expiry: :never
      }

      generate_and_export_key(
          work_directory, key_name, parameters)

      Dir.mktmpdir do |import_home_directory|
        define_task(
            key_file_path: "#{work_directory}/#{key_name}",
            home_directory: import_home_directory)

        Rake::Task['key:import'].invoke

        result = RubyGPG2.list_public_keys(
            home_directory: import_home_directory)

        assert_only_key(result.output.public_keys, parameters)
      end
    end
  end

  it "uses a temporary home directory by default (weird behaviour but " +
      "want to protect user's keychain)" do
    Dir.mktmpdir(nil, '/tmp') do |work_directory|
      key_name = 'gpg.public'
      parameters = {
          owner_name: 'Amanda Greeves',
          owner_email: 'amanda.greeves@example.com',
          owner_comment: nil,
          algorithm: :rsa_encrypt_or_sign,
          key_type: 'RSA',
          key_length: 2048,
          subkey_type: 'RSA',
          subkey_length: 2048,
          expiry: :never
      }

      generate_and_export_key(
          work_directory, key_name, parameters)

      expect(Dir)
          .to(receive(:mktmpdir)
              .with('home', work_directory)
              .and_call_original)

      define_task(
          key_file_path: "#{work_directory}/#{key_name}",
          work_directory: work_directory)

      Rake::Task['key:import'].invoke
    end
  end

  def assert_only_key(public_keys, parameters)
    expect(public_keys.count).to(eq(1))

    public_key = public_keys.first
    expect(public_key.algorithm).to(eq(parameters[:algorithm]))
    expect(public_key.length).to(eq(parameters[:key_length]))

    user_id = public_key.primary_user_id

    expect(user_id.name).to(eq(parameters[:owner_name]))
    expect(user_id.email).to(eq(parameters[:owner_email]))
    expect(user_id.comment).to(eq(parameters[:owner_comment]))
  end

  def generate_and_export_key(work_directory, output_path, parameters = {
          key_type: 'RSA',
          key_length: 2048,
          subkey_type: 'RSA',
          subkey_length: 2048,
          owner_name: 'Amanda Greeves',
          owner_email: 'amanda.greeves@example.com',
          expiry: :never
      })
    Dir.mktmpdir do |generate_home_directory|
      result = RubyGPG2::ParameterFileContents
          .new(parameters)
          .in_temp_file(work_directory) do |f|
        RubyGPG2.generate_key(
            parameter_file_path: f.path,
            home_directory: generate_home_directory,
            work_directory: work_directory,
            without_passphrase: true,
            with_status: true)
      end

      key_fingerprint = result
          .status
          .filter_by_type(:key_created)
          .first_line
          .key_fingerprint

      RubyGPG2.export(
          names: [key_fingerprint],
          output_file_path:
              "#{work_directory}/#{output_path}",
          armor: true,
          home_directory: generate_home_directory)
    end
  end

  def stub_output
    RubyGPG2.configure do |c|
      c.stderr = StringIO.new
      c.stdout = StringIO.new
    end
    [:print, :puts].each do |method|
      allow_any_instance_of(Kernel).to(receive(method))
      allow($stdout).to(receive(method))
      allow($stderr).to(receive(method))
    end
  end
end
