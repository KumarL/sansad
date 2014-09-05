# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'digest/version'

Gem::Specification.new do |spec|
  spec.name          = "digest"
  spec.version       = Digest::VERSION
  spec.authors       = ["Scott Albertson"]
  spec.email         = ["scott@thoughtbot.com"]
  spec.summary       = %q{Create reports the easy way.}
  spec.description   = %q{Like I said, create reports the easy way.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
