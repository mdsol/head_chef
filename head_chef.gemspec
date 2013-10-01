# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'head_chef/version'

Gem::Specification.new do |spec|
  spec.name          = "head_chef"
  spec.version       = HeadChef::VERSION
  spec.authors       = ["Mark Corwin"]
  spec.email         = ["mcorwin@mdsol.com"]
  spec.description   = %q{Head Chef is a chef environment manager built on Berkshelf/Thor} 
  spec.summary       = %q{Chef environment manager}
  spec.homepage      = "https://github.com/mdsol/head_chef"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = 'head_chef'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "thor"
end
