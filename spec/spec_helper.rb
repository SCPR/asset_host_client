require 'combustion'

unless defined?(RAKED)
  Bundler.require :default, :test
  Combustion.initialize!
end

require 'rspec/rails'
require 'fakeweb'

Rails.backtrace_cleaner.remove_silencers!

FakeWeb.allow_net_connect = false

AH_JSON = {
  :asset   => File.read("#{Rails.root}/lib/asset_host/fallback/asset.json"),
  :outputs => File.read("#{Rails.root}/lib/asset_host/fallback/outputs.json")
}

FakeWeb.register_uri(:any, %r|assets\.mysite\.com\/api\/outputs|, body: AH_JSON[:outputs], content_type: "application/json")
FakeWeb.register_uri(:any, %r|assets\.mysite\.com\/api\/assets|, body: AH_JSON[:asset], content_type: "application/json")

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
  config.infer_base_class_for_anonymous_controllers = false
end
