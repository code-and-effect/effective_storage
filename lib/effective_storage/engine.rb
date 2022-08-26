module EffectiveStorage
  class Engine < ::Rails::Engine
    engine_name 'effective_storage'

    # Set up our default configuration options.
    initializer 'effective_storage.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_storage.rb")
    end

    # Include active_storage_attachment_extension concern
    initializer 'effective_storage.active_storage_attachment_extension' do |app|
      app.config.to_prepare do
        ActiveStorage::Blob.include(ActiveStorageBlobExtension)
      end
    end

    # Adds user authorization for all active storage requests
    # Please see upside/app/models/concerns/active_storage_authorization.rb
    # https://github.com/rails/rails/blob/v6.1.4.1/activestorage/app/controllers/active_storage/disk_controller.rb
    initializer 'effective_storage.active_storage_authorization' do |app|
      if EffectiveStorage.authorize_active_storage?
        app.config.to_prepare do
          ActiveStorage::BaseController.class_eval do
            include ActiveStorageAuthorization
          end

          ActiveStorage::DiskController.class_eval do
            before_action :authorize_active_storage_download!, only: [:show]
          end

          ActiveStorage::Blobs::RedirectController.class_eval do
            before_action :authorize_active_storage_redirect!, only: [:show]
          end

          ActiveStorage::Representations::RedirectController.class_eval do
            before_action :authorize_active_storage_redirect!, only: [:show]
          end
        end
      end
    end

  end
end
