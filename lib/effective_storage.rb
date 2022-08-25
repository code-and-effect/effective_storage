require 'effective_resources'
require 'effective_datatables'
require 'effective_storage/engine'
require 'effective_storage/version'

module EffectiveStorage

  def self.config_keys
    [
      :layout
    ]
  end

  include EffectiveGem

end
