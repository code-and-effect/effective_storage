EffectiveStorage.setup do |config|
  # Layout Settings
  # Configure the Layout per controller, or all at once
  # config.layout = { application: 'application', admin: 'admin' }

  # Perform authorization on ActiveStorage downloads
  # When false any request will be permitted (the default)
  config.authorize_active_storage = true

  # Do not delete ActiveStorage::Blobs
  config.never_delete = true

  # Skip Notifications for unauthorized active storage requests
  # config.skip_notification = true
  # config.skip_notification = ['Effective::Classified']

end
