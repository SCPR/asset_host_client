module AssetHostClient
  class Engine < ::Rails::Engine
    config.after_initialize do
      AssetHostClient.fallback_root ||= Rails.root.join('lib', 'asset_host', 'fallback')
    end
  end
end