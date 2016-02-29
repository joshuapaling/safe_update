# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safe_update/version'

Gem::Specification.new do |spec|
  spec.name          = "safe_update"
  spec.version       = SafeUpdate::VERSION
  spec.authors       = ["Joshua Paling"]
  spec.email         = ["joshua.paling@gmail.com"]

  spec.summary       = %q{Safely and automatically update your gems, one at a time, with one git commit per updated gem. }
  spec.homepage      = "https://github.com/joshuapaling/safe_update"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
