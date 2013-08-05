require 'combustion'

unless defined?(RAKED)
  Bundler.require :default, :test
  Combustion.initialize!
end

if ENV['CI']
  # I don't know why
  require 'rails/all'
end

require 'rspec/rails'
require 'fakeweb'

Rails.backtrace_cleaner.remove_silencers!



FakeWeb.allow_net_connect = false

AH_JSON = {
  :asset   => File.read(File.expand_path("spec/fixtures/asset.json")),
  :outputs => File.read(File.expand_path("spec/fixtures/outputs.json"))
}

FakeWeb.register_uri(:any, %r|assets\.mysite\.com\/api\/outputs|, body: AH_JSON[:outputs], content_type: "application/json")
FakeWeb.register_uri(:any, %r|assets\.mysite\.com\/api\/as_asset|, body: AH_JSON[:asset], content_type: "application/json")
FakeWeb.register_uri(:any, %r|assets\.mysite\.com\/api\/assets|, body: AH_JSON[:asset], content_type: "application/json")



Dir[File.expand_path("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
  config.infer_base_class_for_anonymous_controllers = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.include JSONLoader
  
  config.after :each do
    Rails.cache.clear
  end
end
