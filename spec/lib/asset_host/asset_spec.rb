require 'spec_helper'

describe AssetHost::Asset do
  describe "outputs" do
    before :each do
      AssetHost::Asset.instance_variable_set :@outputs, nil
      Rails.cache.clear
    end

    after :all do
      AssetHost::Asset.instance_variable_set :@outputs, nil
      Rails.cache.clear
    end

    it "uses @outputs if it already exists" do
      AssetHost::Asset.instance_variable_set :@outputs, "Outputs"
      AssetHost::Asset.outputs.should eq "Outputs"
    end

    it "uses the cached version if it exists" do
      Rails.cache.read("assets/outputs").should eq nil
      Rails.cache.write("assets/outputs", "OUTPUTS!")
      AssetHost::Asset.outputs.should eq "OUTPUTS!"
    end

    it "sends a request to the api to get outputs" do
      outputs = AssetHost::Asset.outputs
      FakeWeb.last_request.path.should match "/outputs"
    end

    it "returns fallback outputs if the API can't be reached" do
      Faraday::Response.any_instance.stub(:status) { 500 }
      AssetHost::Asset.outputs.should eq(load_fallback("outputs.json"))
    end

    it "writes to cache on successful API response" do
      Rails.cache.should_receive(:write).with("assets/outputs", anything)
      AssetHost::Asset.outputs
    end
  end

  #---------------------

  describe "find" do
    it "returns cached asset json if it exists" do
      Rails.cache.read("asset/asset-1").should eq nil
      AssetHost::Asset.should_receive(:new).with("AssetHost::Asset #1").and_return("Okedoke")
      Rails.cache.write("asset/asset-1", "AssetHost::Asset #1")
      AssetHost::Asset.find(1).should eq "Okedoke"
    end

    it "sends a request to the API on cache miss" do
      asset = AssetHost::Asset.find(1)
      FakeWeb.last_request.path.should match "api/assets/1"
    end

    context "faraday timeout" do
      before :each do
        allow(AssetHost::Asset.connection).to receive(:get).and_raise(Faraday::Error::TimeoutError)
      end

      it "returns a fallback asset" do
        AssetHost::Asset.find(1).should be_a AssetHost::Asset::Fallback
      end
    end

    context "bad response 500" do
      before :each do
        Faraday::Response.any_instance.stub(:status) { 500 }
      end

      it "Returns a fallback asset" do
        AssetHost::Asset.find(1).should be_a AssetHost::Asset::Fallback
      end
    end

    context "bad response 502" do
      before :each do
        Faraday::Response.any_instance.stub(:status) { 502 }
      end

      it "Returns a fallback asset" do
        AssetHost::Asset.find(1).should be_a AssetHost::Asset::Fallback
      end
    end

    context "good response" do
      it "writes to cache" do
        Rails.cache.should_receive(:write).with("asset/asset-1", load_fixture("asset.json"), {expires_in: 30.minute})
        AssetHost::Asset.find(1)
      end

      it "creates a new asset from the json" do
        AssetHost::Asset.should_receive(:new).with(load_fixture("asset.json"))
        AssetHost::Asset.find(1)
      end
    end
  end

  #-------------------

  describe '::create' do
    it 'sends an Asset to the API and builds and object from the response if it is success' do
      asset = AssetHost::Asset.create({ title: "New Asset" })
      asset.should be_a AssetHost::Asset
    end

    it 'returns false if response is not success' do
      Faraday::Response.any_instance.should_receive(:success?).and_return(false)
      asset = AssetHost::Asset.create({ title: "New Asset" })
      asset.should eq false
    end
  end

  #-------------------

  it "generates AssetHost::Asset Sizes for each output" do
    asset = AssetHost::Asset.find(1) # stubbed response
    asset.thumb.should be_a AssetHost::AssetSize
    asset.lsquare.should be_a AssetHost::AssetSize
  end

  describe '#is_rich?' do
    it 'is true for rich assets' do
      asset = AssetHost::Asset.new(load_fixture("asset_with_video.json"))
      asset.is_rich?.should eq true
    end

    it 'is false for non-rich assets' do
      asset = AssetHost::Asset.new(load_fixture("asset.json"))
      asset.is_rich?.should eq false
    end
  end
end
