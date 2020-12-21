# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake_gpg/version'

Gem::Specification.new do |spec|
  spec.name = 'rake_gpg'
  spec.version = RakeGPG::VERSION
  spec.authors = ['Toby Clemson']
  spec.email = ['tobyclemson@gmail.com']

  spec.summary = 'Rake tasks for managing GPG activities.'
  spec.description = 'Rake tasks for common GPG related activities allowing ' +
      'keys to be managed and content to be encrypted and decrypted.'
  spec.homepage = "https://github.com/infrablocks/rake_gpg"
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.add_dependency 'rake_factory', '>= 0.23', '< 1'
  spec.add_dependency 'ruby_gpg2', '>= 0.6', '< 1'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rake_circle_ci', '~> 0.7'
  spec.add_development_dependency 'rake_github', '~> 0.3'
  spec.add_development_dependency 'rake_ssh', '~> 0.2'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'gem-release', '~> 2.0'
  spec.add_development_dependency 'semantic', '~> 1.6.1'
  spec.add_development_dependency 'activesupport', '>= 5.2'
  spec.add_development_dependency 'fakefs', '~> 1.0'
  spec.add_development_dependency 'simplecov', '~> 0.16'
end
