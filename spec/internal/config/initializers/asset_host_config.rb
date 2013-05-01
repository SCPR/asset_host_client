Combustion::Application.configure do
  config.assethost          = ActiveSupport::OrderedOptions.new
  config.assethost.server   = "assets.mysite.com"
  config.assethost.token    = "secrettoken"
  config.assethost.prefix   = "/api"
end
