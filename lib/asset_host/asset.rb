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
          
          response = connection.get "#{config.prefix}/outputs"
          
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
        
        response = connection.get "#{config.prefix}/assets/#{id}"
        json = response.body

        if !GOOD_STATUS.include?(response.status.to_i) || !json
          asset = Fallback.new
        else
          asset = new(json)
          Rails.cache.write(key, json)
        end

        asset
      end


      #-----------------

      def create(attributes={})
        response = connection.post do |request|
          request.url "#{config.prefix}/as_asset"
          request.body = attributes
        end

        json = response.body

        if response.success? && json
          asset = new(json)
          Rails.cache.write("asset/asset-#{asset.id}", json)
        else
          return false
        end

        asset
      end


      def connection
        @connection ||= begin
          Faraday.new(
            :url    => "http://#{config.server}", 
            :params => { auth_token: config.token }
          ) do |conn|
            conn.request :json
            conn.response :json
            conn.adapter Faraday.default_adapter
          end
        end
      end
    end
    
    #----------
    
    ATTRIBUTES = [
      :caption,
      :title,
      :id,
      :size,
      :taken_at,
      :owner,
      :url,
      :api_url,
      :native,
      :image_file_size
    ]

    attr_accessor :json
    attr_accessor *ATTRIBUTES

    def initialize(json)
      @json = json
      @_sizes = {}

      ATTRIBUTES.map(&:to_s).each do |attribute|
        send "#{attribute}=", @json[attribute]
      end
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
