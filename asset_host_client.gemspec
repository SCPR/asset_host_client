# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asset_host_client/version'

Gem::Specification.new do |spec|
  spec.name          = "asset_host_client"
  spec.version       = AssetHostClient::VERSION
  spec.authors       = ["Bryan Ricker", "Eric Richardson"]
  spec.email         = ["bricker88@gmail.com"]
  spec.description   = %q{Ruby client for AssetHost}
  spec.summary       = %q{Ruby client for AssetHost API interaction.}
  spec.homepage      = "https://github.com/SCPR/asset_host_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", [">= 3.0", "< 5"]
  spec.add_dependency "faraday", "~> 0.8"
  spec.add_dependency "faraday_middleware", "~> 0.8"

  spec.add_development_dependency "bundler", "~> 1.3"
end
