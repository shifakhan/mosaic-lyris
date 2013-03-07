# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mosaic/lyris/version'

Gem::Specification.new do |gem|
  gem.name = "mosaic-lyris"
  gem.version = Mosaic::Lyris::VERSION
  gem.date = Date.today.to_s

  gem.summary = "Lyris/EmailLabs API"
  gem.description = "A wrapper for the Lyris/EmailLabs API to simplify integration"

  gem.authors = ["S. Brent Faulkner"]
  gem.email = "brent.faulkner@mosaic.com"
  gem.homepage = "http://github.com/mosaicxm/mosaic-lyris"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "builder", [">= 0"]
  gem.add_runtime_dependency "active_support", [">= 0"]
  gem.add_runtime_dependency "htmlentities", [">= 0"]
  gem.add_runtime_dependency "nokogiri", [">= 0"]
  gem.add_runtime_dependency "tzinfo", [">= 0"]

  gem.add_development_dependency "rake", [">= 0"]
  gem.add_development_dependency "mocha", [">= 0"]
end

