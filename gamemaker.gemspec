# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamemaker/version'

Gem::Specification.new do |spec|
  spec.name          = "gamemaker"
  spec.version       = Gamemaker::VERSION
  spec.authors       = ["Godfrey Chan"]
  spec.email         = ["godfreykfc@gmail.com"]

  spec.summary       = "Shared utils for gamemaker.io"
  spec.homepage      = "http://gamemaker.io"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 4.2.0"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
