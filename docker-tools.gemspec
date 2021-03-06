# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "docker/tools/version"

Gem::Specification.new do |spec|
  spec.name          = "docker-tools"
  spec.version       = Docker::Tools::VERSION
  spec.authors       = ["Jon Frisby"]
  spec.email         = ["jfrisby@mrjoy.com"]
  spec.summary       = "Shared tools for Rake and Docker workflows."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"

  spec.add_runtime_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "activesupport", "> 4.0"
  spec.add_runtime_dependency "foreman", "> 0"
  spec.add_runtime_dependency "bundler-audit", "> 0"
  spec.add_runtime_dependency "rubocop", "> 0"
  spec.add_runtime_dependency "pry", "> 0"
  spec.add_runtime_dependency "nokogiri", "> 0"
  spec.add_runtime_dependency "dotenv", "> 0"
end
