# frozen_string_literal: true

require_relative "lib/database_copy/version"

Gem::Specification.new do |spec|
  spec.name = "database_copy"
  spec.version = DatabaseCopy::VERSION
  spec.authors = ["Mario Alberto Chávez"]
  spec.email = ["mario.chavez@gmail.com"]

  spec.summary = "A Ruby gem for a simple way to copy data from one PostgreSQL database to a blank one."
  spec.description = "This gem simplifies the process of database migration or replication by providing a straightforward interface to copy tables and their data, while allowing fine-grained control over the selection of tables and attributes."
  spec.homepage = "https://aoorora.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.2"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/creditario/database_copy"
  spec.metadata["changelog_uri"] = "https://github.com/creditario/database_copy/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "pg", "~> 1.5", ">= 1.5.3"
  spec.add_dependency "tty-spinner", "~> 0.9.3"
  spec.add_dependency "pastel", "~> 0.8.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
