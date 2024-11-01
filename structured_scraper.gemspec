# frozen_string_literal: true

require_relative "lib/structured_scraper/version"

Gem::Specification.new do |spec|
  spec.name = "structured_scraper"
  spec.version = StructuredScraper::VERSION
  spec.authors = ["Chris"]
  spec.email = ["chris@dogcow.co.uk"]

  spec.summary = "Yet another DSL for scraping web pages."
  spec.description = "structured_scraper is a simple DSL for extracting content from HTML into a user-defined data structure using CSS and XPath selectors."
  spec.homepage = "https://github.com/newdogcow/structured_scraper"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/newdogcow/structured_scraper"
  spec.metadata["changelog_uri"] = "https://github.com/newdogcow/structured_scraper/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.16"
end
