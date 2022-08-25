# This is included into ActiveStorage::Attachment automatically by engine.rb
module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_one :active_storage_extension, class_name: 'Effective::ActiveStorageExtension', inverse_of: :attachment, dependent: :destroy
    accepts_nested_attributes_for :active_storage_extension, allow_destroy: true
  end

  module ClassMethods
  end

  # Instance methods
  def permission_default?
    active_storage_extension.blank? || active_storage_extension.permission_default?
  end

  def permission_public?
    active_storage_extension.present? && active_storage_extension.permission_public?
  end

end
