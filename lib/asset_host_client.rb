require "asset_host_client/version"
require "asset_host_client/engine"
require 'asset_host'

module AssetHostClient
  class << self
    mattr_accessor :fallback_root, :server, :prefix, :token, :raise_on_errors, :protocol

    # set some defaults
    self.prefix           = "/api"
    self.raise_on_errors  = false
  end

  def self.setup
    yield self
  end
end
