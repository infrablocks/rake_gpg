# frozen_string_literal: true

require 'rake_gpg/tasks'
require 'rake_gpg/version'

module RakeGPG
  def self.define_encrypt_task(opts = {}, &)
    RakeGPG::Tasks::Encryption::Encrypt.define(opts, &)
  end

  def self.define_decrypt_task(opts = {}, &)
    RakeGPG::Tasks::Encryption::Decrypt.define(opts, &)
  end

  def self.define_generate_key_task(opts = {}, &)
    RakeGPG::Tasks::Keys::Generate.define(opts, &)
  end

  def self.define_import_key_task(opts = {}, &)
    RakeGPG::Tasks::Keys::Import.define(opts, &)
  end
end
