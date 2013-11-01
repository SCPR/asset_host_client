require "asset_host/asset"
require "asset_host/asset_size"

module AssetHost
  def self.fallback_root=(val)
    @fallback_root = val
  end

  def self.fallback_root
    @fallback_root ||= Rails.root.join('lib', 'asset_host', 'fallback')
  end
end
