# AssetHostClient

Client for AssetHost API interaction.


## Installation

    gem 'asset_host_client'

The gem is "AssetHostClient", so it doesn't get mixed up with "AssetHost".
However, it creates and/or extends the "AssetHost" module.


## Usage

`AssetHost::Asset.find(asset_id)`

You should also provide fallback JSON files at 
`lib/asset_host_client/fallback/asset.json` and 
`lib/asset_host_client/fallback/outputs.json`.

This is so that if the API is unavailable for some reason, it won't bring
your entire website down. You can override that path by setting
`AssetHost.fallback_root = Rails.root.join('lib', 'fallbacks')` 
in an initializer.


## Contributing

Sure!
