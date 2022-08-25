module EffectiveStorage
  class Engine < ::Rails::Engine
    engine_name 'effective_storage'

    # Set up our default configuration options.
    initializer 'effective_storage.defaults', before: :load_config_initializers do |app|
      eval File.read("#{config.root}/config/effective_storage.rb")
    end

  end
end
