# frozen_string_literal: true

require 'rake_gpg/tasks'
require 'rake_gpg/version'

module RakeGPG
  def self.define_encrypt_task(opts = {}, &block)
    RakeGPG::Tasks::Encryption::Encrypt.define(opts, &block)
  end

  def self.define_decrypt_task(opts = {}, &block)
    RakeGPG::Tasks::Encryption::Decrypt.define(opts, &block)
  end

  def self.define_generate_key_task(opts = {}, &block)
    RakeGPG::Tasks::Keys::Generate.define(opts, &block)
  end

  def self.define_import_key_task(opts = {}, &block)
    RakeGPG::Tasks::Keys::Import.define(opts, &block)
  end
end
