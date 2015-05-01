# AssetHostClient

Simple Ruby client for the AssetHost API.

[![Build Status](https://travis-ci.org/SCPR/asset_host_client.png?branch=master)](https://travis-ci.org/SCPR/asset_host_client)


## Installation

    gem 'asset_host_client'

The gem is "AssetHostClient", so it doesn't get mixed up with "AssetHost".
However, it creates and/or extends the "AssetHost" module.


## Usage

### Configuration

Configure your app to connect to assethost, either in an initializer or your environment files:

```ruby
  AssetHostClient.setup do |config|
    config.server  = "assets.yoursite.org"
    config.token  = "{your assethost token}"
    config.prefix  = "/api"
  end
```


### Finding

`AssetHost::Asset.find(asset_id)`

You should also provide fallback JSON files at
`lib/asset_host_client/fallback/asset.json` and
`lib/asset_host_client/fallback/outputs.json`.

This is so that if the API is unavailable for some reason, it won't bring
your entire website down. You can override that path by setting
`config.fallback_root = Rails.root.join('lib', 'fallbacks')`
in your initializer.


### Creating

`AssetHost::Asset.create(attributes)`


## Contributing

Sure!

`rake test` to run tests.
