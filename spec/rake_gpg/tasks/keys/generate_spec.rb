require 'spec_helper'
require 'ruby_gpg2'

describe RakeGPG::Tasks::Keys::Generate do
  include_context :rake
  include_context :gpg

  before(:each) do
    stub_output
  end

  after(:each) do
    RubyGPG2.reset!
  end

  def define_task(opts = {}, &block)
    opts = {namespace: :key}.merge(opts)

    namespace opts[:namespace] do
      subject.define(opts, &block)
    end
  end

  it 'adds a generate task in the namespace in which it is created' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    expect(Rake::Task.task_defined?('key:generate'))
        .to(be(true))
  end

  it 'gives the generate task a description' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    expect(Rake::Task['key:generate'].full_comment)
        .to(eq('Generate a GPG key'))
  end

  it 'fails if no owner name is provided' do
    define_task(
        owner_email: "joe.bloggs@example.com")

    expect {
      Rake::Task['key:generate'].invoke
    }.to raise_error(RakeFactory::RequiredParameterUnset)
  end

  it 'has no output directory by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.output_directory).to(be_nil)
  end

  it 'uses the provided output directory when specified' do
    output_directory = 'some/key/path'

    define_task(
        output_directory: output_directory,
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.output_directory).to(eq(output_directory))
  end

  it 'uses a name prefix of gpg by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.name_prefix).to(eq('gpg'))
  end

  it 'uses the provided name prefix when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        name_prefix: 'admin')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.name_prefix).to(eq('admin'))
  end

  it 'uses armor by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.armor).to(be(true))
  end

  it 'uses the provided value for armor when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        armor: false)

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.armor).to(be(false))
  end

  it 'uses a work directory of /tmp by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq('/tmp'))
  end

  it 'uses the provided work directory when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        work_directory: 'tmp')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.work_directory).to(eq('tmp'))
  end

  it 'uses a temporary home directory by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq(:temporary))
  end

  it 'uses the provided home directory when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        home_directory: 'tmp')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.home_directory).to(eq('tmp'))
  end

  it 'has no owner comment by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.owner_comment).to(be_nil)
  end

  it 'uses the provided owner comment when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        owner_comment: "Work")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.owner_comment).to(eq("Work"))
  end

  it 'uses a key type of RSA by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.key_type).to(eq('RSA'))
  end

  it 'uses the provided key type when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        key_type: 'DSA')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.key_type).to(eq('DSA'))
  end

  it 'uses a key length of 2048 by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.key_length).to(eq(2048))
  end

  it 'uses the provided key length when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        key_length: 4096)

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.key_length).to(eq(4096))
  end

  it 'uses a subkey type of RSA by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.subkey_type).to(eq('RSA'))
  end

  it 'uses the provided subkey type when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        subkey_type: 'DSA')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.subkey_type).to(eq('DSA'))
  end

  it 'uses a subkey length of 2048 by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.subkey_length).to(eq(2048))
  end

  it 'uses the provided subkey length when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        subkey_length: 4096)

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.subkey_length).to(eq(4096))
  end

  it 'uses an expiry of never by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.expiry).to(eq(:never))
  end

  it 'uses the provided expiry when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        expiry: '2y')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.expiry).to(eq('2y'))
  end

  it 'uses no passphrase by default' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com")

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.passphrase).to(be_nil)
  end

  it 'uses the provided passphrase when specified' do
    define_task(
        owner_name: "Joe Bloggs",
        owner_email: "joe.bloggs@example.com",
        passphrase: 'some-passphrase')

    rake_task = Rake::Task['key:generate']
    test_task = rake_task.creator

    expect(test_task.passphrase).to(eq('some-passphrase'))
  end

  it 'creates a gpg key in the specified home directory' do
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"
      home_directory = "#{temp_directory}/home"

      owner_name = 'Amanda Greeves'
      owner_email = 'amanda.greeves@example.com'

      define_task(
          owner_name: owner_name,
          owner_email: owner_email,
          work_directory: work_directory,
          home_directory: home_directory)

      Rake::Task['key:generate'].invoke

      result = RubyGPG2.list_public_keys(
          home_directory: home_directory)

      public_keys = result.output.public_keys

      expect(public_keys.count).to(eq(1))

      public_key = public_keys.first
      expect(public_key.algorithm).to(eq(:rsa_encrypt_or_sign))
      expect(public_key.length).to(eq(2048))

      user_id = public_key.primary_user_id

      expect(user_id.name).to(eq(owner_name))
      expect(user_id.email).to(eq(owner_email))
      expect(user_id.comment).to(be_nil)
    end
  end

  it 'exports the gpg key to the provided output directory when specified' do
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"
      output_directory = "#{temp_directory}/some/key/path"

      passphrase = 'secret-passphrase'

      owner_name = 'Amanda Greeves'
      owner_email = 'amanda.greeves@example.com'

      Dir.mktmpdir(nil, '/tmp') do |generate_home_directory|
        define_task(
            passphrase: passphrase,
            work_directory: work_directory,
            output_directory: output_directory,
            owner_name: owner_name,
            owner_email: owner_email,
            home_directory: generate_home_directory)

        Rake::Task['key:generate'].invoke
      end

      public_key_path = "#{output_directory}/gpg.public"
      secret_key_path = "#{output_directory}/gpg.private"

      expect(File.exist?(public_key_path)).to(be(true))
      expect(File.exist?(secret_key_path)).to(be(true))

      Dir.mktmpdir(nil, '/tmp') do |public_import_home_directory|
        import_key(
            temp_directory,
            public_import_home_directory,
            public_key_path)

        result = RubyGPG2.list_public_keys(
            home_directory: public_import_home_directory)

        public_keys = result.output.public_keys

        expect(public_keys.count).to(eq(1))

        public_key = public_keys.first
        expect(public_key.algorithm).to(eq(:rsa_encrypt_or_sign))
        expect(public_key.length).to(eq(2048))

        user_id = public_key.primary_user_id

        expect(user_id.name).to(eq(owner_name))
        expect(user_id.email).to(eq(owner_email))
        expect(user_id.comment).to(be_nil)
      end

      Dir.mktmpdir(nil, '/tmp') do |secret_import_home_directory|
        import_key(
            temp_directory,
            secret_import_home_directory,
            secret_key_path)

        result = RubyGPG2.list_secret_keys(
            home_directory: secret_import_home_directory)

        secret_keys = result.output.secret_keys

        expect(secret_keys.count).to(eq(1))

        secret_key = secret_keys.first
        expect(secret_key.algorithm).to(eq(:rsa_encrypt_or_sign))
        expect(secret_key.length).to(eq(2048))

        user_id = secret_key.primary_user_id

        expect(user_id.name).to(eq(owner_name))
        expect(user_id.email).to(eq(owner_email))
        expect(user_id.comment).to(be_nil)
      end
    end
  end

  it 'creates a temporary directory under the work directory for home ' +
      'directory when home directory is :temporary' do
    Dir.mktmpdir(nil, '/tmp') do |temp_directory|
      work_directory = "#{temp_directory}/work"
      output_directory = "#{temp_directory}/keys"
      owner_name = 'Amanda Greeves'
      owner_email = 'amanda.greeves@example.com'

      define_task(
          owner_name: owner_name,
          owner_email: owner_email,
          work_directory: work_directory,
          home_directory: :temporary,
          output_directory: output_directory)

      expect(Dir)
          .to(receive(:mktmpdir)
              .with('home', work_directory)
              .and_call_original)

      Rake::Task['key:generate'].invoke

      public_key_path = "#{output_directory}/gpg.public"
      secret_key_path = "#{output_directory}/gpg.private"

      expect(File.exist?(public_key_path)).to(be(true))
      expect(File.exist?(secret_key_path)).to(be(true))
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

