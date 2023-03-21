require 'effective_resources'
require 'effective_datatables'
require 'effective_storage/engine'
require 'effective_storage/version'

module EffectiveStorage

  def self.config_keys
    [:layout, :authorize_active_storage, :never_delete, :skip_notification]
  end

  include EffectiveGem

  def self.authorize_active_storage?
    authorize_active_storage == true
  end

  def self.never_delete?
    never_delete == true
  end

  def self.skip_notification?
    skip_notification == true
  end

  def self.skip_notifications
    Array(skip_notification)
  end

end
