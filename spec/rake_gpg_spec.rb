# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RakeGPG do
  it 'has a version number' do
    expect(RakeGPG::VERSION).not_to be_nil
  end

  describe 'define_encrypt_task' do
    context 'when instantiating RakeGPG::Tasks::Encryption::Encrypt' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'passes the provided block' do
        opts = {
          key_file_path: 'some/gpg/key',
          input_file_path: 'some/file/to/encrypt',
          output_file_path: 'some/output/file'
        }

        block = lambda do |t|
          t.armor = false
        end

        allow(RakeGPG::Tasks::Encryption::Encrypt).to(receive(:define))

        described_class.define_encrypt_task(opts, &block)

        expect(RakeGPG::Tasks::Encryption::Encrypt)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'define_decrypt_task' do
    context 'when instantiating RakeGPG::Tasks::Encryption::Decrypt' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'passes the provided block' do
        opts = {
          key_file_path: 'some/gpg/key',
          input_file_path: 'some/file/to/encrypt',
          output_file_path: 'some/output/file'
        }

        block = lambda do |t|
          t.passphrase = 'super-secret-passphrase'
        end

        allow(RakeGPG::Tasks::Encryption::Decrypt).to(receive(:define))

        described_class.define_decrypt_task(opts, &block)

        expect(RakeGPG::Tasks::Encryption::Decrypt)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'define_generate_key_task' do
    context 'when instantiating RakeGPG::Tasks::Keys::Generate' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'passes the provided block' do
        opts = {
          owner_name: 'Joe Bloggs',
          owner_email: 'joe.bloggs@example.com'
        }

        block = lambda do |t|
          t.passphrase = 'super-secret-passphrase'
        end

        allow(RakeGPG::Tasks::Keys::Generate).to(receive(:define))

        described_class.define_generate_key_task(opts, &block)

        expect(RakeGPG::Tasks::Keys::Generate)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end

  describe 'define_import_key_task' do
    context 'when instantiating RakeGPG::Tasks::Keys::Import' do
      # rubocop:disable RSpec/MultipleExpectations
      it 'passes the provided block' do
        opts = {
          key_file_path: 'some/key/path'
        }

        block = lambda do |t|
          t.work_directory = '/tmp'
        end

        allow(RakeGPG::Tasks::Keys::Import).to(receive(:define))

        described_class.define_import_key_task(opts, &block)

        expect(RakeGPG::Tasks::Keys::Import)
          .to(have_received(:define) do |passed_opts, &passed_block|
            expect(passed_opts).to(eq(opts))
            expect(passed_block).to(eq(block))
          end)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
