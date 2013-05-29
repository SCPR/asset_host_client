require 'faraday'
require 'faraday_middleware'

module AssetHost
  class Asset
    class Fallback < Asset
      def initialize
        json = JSON.parse(File.read(File.join(AssetHost.fallback_root, "asset.json")))
        super(json)
      end
    end

    BAD_STATUS  = [400, 404, 500, 502]
    GOOD_STATUS = [200]
    
    #-------------------
    
    class << self
      def config
        @config ||= Rails.application.config.assethost
      end
      
      #-------------------
      
      def outputs
        @outputs ||= begin
          key = "assets/outputs"

          if cached = Rails.cache.read(key)
            return cached
          end
          
          response = connection.get "#{config.prefix}/outputs" do |request|
            request.headers['Content-Type'] = 'application/json'
          end
          
          if !GOOD_STATUS.include? response.status
            outputs = JSON.parse(File.read(File.join(AssetHost.fallback_root, "outputs.json")))
          else
            outputs = response.body
            Rails.cache.write(key, outputs)
          end
          
          outputs
        end
      end
    
      #-------------------
      
      # asset = Asset.find(id)
      # Given an asset ID, returns an asset object
      def find(id)
        key = "asset/asset-#{id}"
        
        if cached = Rails.cache.read(key)
          return new(cached)
        end
        
        response = connection.get "#{config.prefix}/assets/#{id}" do |request|
          request.headers['Content-Type'] = 'application/json'
        end

        if !GOOD_STATUS.include? response.status
          asset = Fallback.new
        else
          json = response.body
          Rails.cache.write(key, json)
          asset = new(json)
        end

        asset
      end


      #-----------------

      def create(attributes={})
        response = connection.post do |request|
          request.url "#{Rails.application.config.assethost.prefix}/as_asset"
          request.params = request.params.merge(attributes)
          request.headers['Content-Type'] = "application/json"
        end

        if response.success?
          new(response.body)
        else
          false
        end
      end


      def connection
        @connection ||= begin
          Faraday.new(
            :url    => "http://#{Rails.application.config.assethost.server}", 
            :params => { auth_token: Rails.application.config.assethost.token }
          ) do |conn|
            conn.response :json
            conn.adapter Faraday.default_adapter
          end
        end
      end
    end
    
    #----------
    
    attr_accessor :json, :caption, :title, :id, :size, :taken_at, :owner, :url, :api_url, :native, :image_file_size

    def initialize(json)
      @json = json
      @_sizes = {}

      # define some attributes
      [
        :caption, :title, :id, :size,
        :taken_at, :owner, :url, :api_url,
        :native, :image_file_size
      ].each { |key| self.send("#{key}=", @json[key.to_s]) }
    end
    
    #----------
    
    def _size(output)
      @_sizes[ output['code'] ] ||= AssetSize.new(self, output)
    end
    
    #----------
    
    def as_json(options={})
      @json
    end

    def method_missing(method, *args)
      if output = Asset.outputs.find { |output| output['code'] == method.to_s }
        self._size(output)
      else
        super
      end
    end
  end
end
