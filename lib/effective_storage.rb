require 'effective_resources'
require 'effective_datatables'
require 'effective_storage/engine'
require 'effective_storage/version'

module EffectiveStorage

  def self.config_keys
    [:layout, :authorize_active_storage, :never_delete]
  end

  include EffectiveGem

  def self.authorize_active_storage?
    authorize_active_storage == true
  end

  def self.never_delete?
    never_delete == true
  end

end
