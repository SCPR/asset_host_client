module AssetHost
  class AssetSize
    attr_accessor  :width, :height, :tag, :url, :asset, :output
      
    def initialize(asset,output)
      @asset  = asset
      @output = output
      
      self.width  = @asset.json['sizes'][ output['code'] ]['width']
      self.height = @asset.json['sizes'][ output['code'] ]['height']
      self.tag    = @asset.json['tags'][ output['code'] ]
      self.url    = @asset.json['urls'][ output['code'] ]
    end
    
    def tag
      @tag.html_safe
    end
  end
end
