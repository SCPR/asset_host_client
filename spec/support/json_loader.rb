module JSONLoader
  def load_fallback(filename)
    load_json(File.join(AssetHostClient.fallback_root, filename))
  end

  def load_fixture(filename)
    load_json(File.expand_path("spec/fixtures/#{filename}"))
  end

  def load_json(filename)
    JSON.parse(File.read(filename))
  end
end
