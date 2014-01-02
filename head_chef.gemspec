# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'head_chef/version'

Gem::Specification.new do |spec|
  spec.name          = "head_chef"
  spec.version       = HeadChef::VERSION
  spec.authors       = ["Mark Corwin"]
  spec.email         = ["mcorwin@mdsol.com"]
  spec.description   = %q{Head Chef is a Chef workflow CLI built on Berkshelf}
  spec.summary       = %q{Chef workflow tool}
  spec.homepage      = "https://github.com/mdsol/head_chef"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "chef-zero"
  spec.add_development_dependency "erubis"
  spec.add_development_dependency "ridley"
  spec.add_development_dependency "hashie"

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "grit"
  spec.add_runtime_dependency "berkshelf"
  spec.add_runtime_dependency "ridley"
  spec.add_runtime_dependency "semantic"
end
