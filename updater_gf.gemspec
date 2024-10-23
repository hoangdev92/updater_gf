# frozen_string_literal: true

require_relative 'lib/updater_gf/version'

Gem::Specification.new do |spec|
  spec.name = 'updater_gf'
  spec.version = UpdaterGf::VERSION
  spec.authors = ['devhoanglv92']
  spec.email = ['devhoanglv92@gmail.com']

  spec.summary = 'update Gemfile and clean code file'
  spec.description = 'update Gemfile and clean code file by updater_gf'
  spec.homepage = 'https://github.com/hoangdev92/updater_gf'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.5'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/hoangdev92/updater_gf'
  spec.metadata['changelog_uri'] = 'https://github.com/hoangdev92/updater_gf/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.executables << 'updater_gf'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
