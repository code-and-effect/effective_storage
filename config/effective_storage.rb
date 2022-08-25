EffectiveStorage.setup do |config|
  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Perform authorization on ActiveStorage downloads
  # When false any request will be permitted (the default)
  config.authorize_active_storage = true
end
