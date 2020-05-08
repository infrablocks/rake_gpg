require 'spec_helper'

RSpec.describe RakeGPG do
  it 'has a version number' do
    expect(RakeGPG::VERSION).not_to be nil
  end

  context 'define_encrypt_task' do
    context 'when instantiating RakeGPG::Tasks::Encryption::Encrypt' do
      it 'passes the provided block' do
        opts = {
            key_file_path: 'some/gpg/key',
            input_file_path: 'some/file/to/encrypt',
            output_file_path: 'some/output/file',
        }

        block = lambda do |t|
          t.armor = false
        end

        expect(RakeGPG::Tasks::Encryption::Encrypt)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeGPG.define_encrypt_task(opts, &block)
      end
    end
  end

  context 'define_decrypt_task' do
    context 'when instantiating RakeGPG::Tasks::Encryption::Decrypt' do
      it 'passes the provided block' do
        opts = {
            key_file_path: 'some/gpg/key',
            input_file_path: 'some/file/to/encrypt',
            output_file_path: 'some/output/file',
        }

        block = lambda do |t|
          t.passphrase = "super-secret-passphrase"
        end

        expect(RakeGPG::Tasks::Encryption::Decrypt)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeGPG.define_decrypt_task(opts, &block)
      end
    end
  end

  context 'define_generate_key_task' do
    context 'when instantiating RakeGPG::Tasks::Keys::Generate' do
      it 'passes the provided block' do
        opts = {
            owner_name: "Joe Bloggs",
            owner_email: "joe.bloggs@example.com",
        }

        block = lambda do |t|
          t.passphrase = "super-secret-passphrase"
        end

        expect(RakeGPG::Tasks::Keys::Generate)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeGPG.define_generate_key_task(opts, &block)
      end
    end
  end

  context 'define_import_key_task' do
    context 'when instantiating RakeGPG::Tasks::Keys::Import' do
      it 'passes the provided block' do
        opts = {
            key_file_path: 'some/key/path'
        }

        block = lambda do |t|
          t.work_directory = '/tmp'
        end

        expect(RakeGPG::Tasks::Keys::Import)
            .to(receive(:define) do |passed_opts, &passed_block|
              expect(passed_opts).to(eq(opts))
              expect(passed_block).to(eq(block))
            end)

        RakeGPG.define_import_key_task(opts, &block)
      end
    end
  end
end
