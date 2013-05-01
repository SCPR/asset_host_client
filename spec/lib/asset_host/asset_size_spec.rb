require 'spec_helper'

describe AssetHost::AssetSize do
  it "provides access to the asset attributes" do
    output = AssetHost::Asset.outputs.first
    asset  = AssetHost::Asset.find(1)
    size   = AssetHost::AssetSize.new(asset, output)

    size.width.should be_present
    size.height.should be_present
    size.tag.should be_present
    size.url.should be_present
  end
end
