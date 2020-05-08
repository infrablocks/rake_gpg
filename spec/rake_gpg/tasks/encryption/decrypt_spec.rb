require 'spec_helper'
require 'ruby_gpg2'

describe RakeGPG::Tasks::Encryption::Decrypt do
  include_context :rake
  include_context :gpg

  before(:each) do
    stub_output
  end

  after(:each) do
    RubyGPG2.reset!
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :encryption}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds an decrypt task in the namespace in which it is created' do
    define_task(
        key_file_path: 'some/gpg/key',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    expect(Rake::Task.task_defined?('encryption:decrypt'))
        .to(be(true))
  end

  it 'gives the decrypt task a description' do
    define_task(
        key_file_path: 'some/gpg/key',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    expect(Rake::Task['encryption:decrypt'].full_comment)
        .to(eq('Decrypt a file using GPG'))
  end

  it 'fails if no key file path is provided' do
    define_task(
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    expect {
      Rake::Task['encryption:decrypt'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no input file path is provided' do
    define_task(
        key_file_path: 'some/gpg/key',
        output_file_path: 'some/output/file')

    expect {
      Rake::Task['encryption:decrypt'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'fails if no output file path is provided' do
    define_task(
        key_file_path: 'some/gpg/key',
        input_file_path: 'some/file/to/decrypt')

    expect {
      Rake::Task['encryption:decrypt'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'uses a work directory of build/gpg by default' do
    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq('build/gpg'))
  end

  it 'uses the provided work directory when specified' do
    work_directory = 'some/work/directory'

    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file',
        work_directory: work_directory)

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq(work_directory))
  end

  it 'uses a home directory of :temporary by default' do
    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(:temporary))
  end

  it 'uses the provided home directory when specified' do
    home_directory = 'some/home/directory'

    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file',
        home_directory: home_directory)

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(home_directory))
  end

  it 'uses a trust mode of always by default' do
    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.trust_mode).to(be(:always))
  end

  it 'uses the provided value for trust mode when specified' do
    trust_mode = :classic

    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file',
        trust_mode: trust_mode)

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.trust_mode).to(be(:classic))
  end

  it 'uses no passphrase by default' do
    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file')

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.passphrase).to(be_nil)
  end

  it 'uses the provided passphrase when specified' do
    passphrase = 'super-secure-passphrase'

    define_task(
        key_file_path: 'some/key/path',
        input_file_path: 'some/file/to/decrypt',
        output_file_path: 'some/output/file',
        passphrase: passphrase)

    rake_task = Rake::Task['encryption:decrypt']
    test_task = rake_task.creator

    expect(test_task.passphrase).to(be(passphrase))
  end

  it 'decrypts a file for the provided key' do
    Dir.mktmpdir(nil, '/tmp') do |work_directory|
      secret_key_name = 'gpg.private'

      secret_key_file_path = "#{work_directory}/#{secret_key_name}"

      input_file_path = "#{work_directory}/some-file.plain"
      encrypted_file_path = "#{work_directory}/some-file.encrypted"
      decrypted_file_path = "#{work_directory}/some-file.decrypted"

      File.open(input_file_path, 'w') do |f|
        f.write("Hello world")
      end

      Dir.mktmpdir do |encrypt_home_directory|
        key_fingerprint =
            generate_key(
                work_directory, encrypt_home_directory)
        export_secret_key(
            work_directory,
            encrypt_home_directory,
            secret_key_name,
            key_fingerprint)

        RubyGPG2.encrypt(
            recipient: key_fingerprint,
            input_file_path: input_file_path,
            output_file_path: encrypted_file_path,
            home_directory: encrypt_home_directory,
            armor: true,
            trust_mode: :always)
      end

      define_task(
          key_file_path: secret_key_file_path,
          input_file_path: encrypted_file_path,
          output_file_path: decrypted_file_path,
          work_directory: work_directory)

      Rake::Task['encryption:decrypt'].invoke

      expect(File.read(decrypted_file_path)).to(eq('Hello world'))
    end
  end

  it 'uses a passphrase for decryption when supplied' do
    Dir.mktmpdir(nil, '/tmp') do |work_directory|
      passphrase = 'super-secure-passphrase'

      secret_key_name = 'gpg.private'
      secret_key_file_path = "#{work_directory}/#{secret_key_name}"

      input_file_path = "#{work_directory}/some-file.plain"
      encrypted_file_path = "#{work_directory}/some-file.encrypted"
      decrypted_file_path = "#{work_directory}/some-file.decrypted"

      File.open(input_file_path, 'w') do |f|
        f.write("Hello world")
      end

      Dir.mktmpdir do |encrypt_home_directory|
        key_fingerprint =
            generate_key(
                work_directory,
                encrypt_home_directory,
                passphrase: passphrase)
        export_secret_key(
            work_directory,
            encrypt_home_directory,
            secret_key_name,
            key_fingerprint,
            passphrase: passphrase)

        RubyGPG2.encrypt(
            recipient: key_fingerprint,
            input_file_path: input_file_path,
            output_file_path: encrypted_file_path,
            home_directory: encrypt_home_directory,
            armor: true,
            trust_mode: :always)
      end

      define_task(
          key_file_path: secret_key_file_path,
          passphrase: passphrase,
          input_file_path: encrypted_file_path,
          output_file_path: decrypted_file_path,
          work_directory: work_directory)

      Rake::Task['encryption:decrypt'].invoke

      expect(File.read(decrypted_file_path)).to(eq('Hello world'))
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
