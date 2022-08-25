require 'effective_resources'
require 'effective_datatables'
require 'effective_storage/engine'
require 'effective_storage/version'

module EffectiveStorage

  def self.config_keys
    [:layout, :authorize_active_storage]
  end

  include EffectiveGem

  def self.authorize_active_storage?
    authorize_active_storage == true
  end

end
