Combustion::Application.configure do
  AssetHostClient.setup do |config|
    config.server   = "assets.mysite.com"
    config.token    = "secrettoken"
    config.prefix   = "/api"
  end
end
