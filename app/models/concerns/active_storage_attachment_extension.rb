# This is included into ActiveStorage::Attachment automatically by engine.rb
module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    has_many :active_storage_extensions, class_name: 'Effective::ActiveStorageExtension', inverse_of: :attachment, dependent: :destroy
    accepts_nested_attributes_for :active_storage_extensions, allow_destroy: true

    scope :deep, -> { includes(:active_storage_extensions, :blob, record: :record) }
  end

  module ClassMethods
  end

  # Instance methods

  def to_s
    'attachment'
  end

  # Find or build
  def active_storage_extension
    active_storage_extensions.to_a.first || active_storage_extensions.build(permission: 'inherited')
  end

  def permission
    active_storage_extension.permission
  end

  def permission_inherited?
    permission == 'inherited'
  end

  def permission_public?
    permission == 'public'
  end

  def mark_inherited!
    active_storage_extension.assign_attributes(permission: 'inherited')
    save!
  end

  def mark_public!
    active_storage_extension.assign_attributes(permission: 'public')
    save!
  end

end
