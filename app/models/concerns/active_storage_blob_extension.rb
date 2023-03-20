# This is included into ActiveStorage::Attachment automatically by engine.rb
module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do
    has_many :active_storage_extensions, class_name: 'Effective::ActiveStorageExtension', inverse_of: :blob, dependent: :destroy
    accepts_nested_attributes_for :active_storage_extensions, allow_destroy: true

    scope :deep, -> { includes(:active_storage_extensions, attachments: [record: :record]) }

    scope :attached, -> { joins(:attachments) }
    scope :unattached, -> { where.not(id: attached) }

  end

  module ClassMethods
  end

  # Instance methods

  def to_s
    filename.presence || 'blob'
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

  # The purge! command is not part of the regular ActiveStorage::Blob class
  # This is the command called by the admin/storage datatable
  # When config.never_delete_active_storage is enabled, this is the only way to delete a Blob
  # And they will not be deleted in the background.
  def purge!
    before = EffectiveStorage.never_delete

    begin
      EffectiveStorage.never_delete = false
      purge
    ensure
      EffectiveStorage.never_delete = before
    end
  end

  def delete
    if EffectiveStorage.never_delete?
      Rails.logger.info "[effective_storage] Skipping ActiveStorage::Blob delete"
      return
    end

    super
  end

  def destroy
    if EffectiveStorage.never_delete?
      Rails.logger.info "[effective_storage] Skipping ActiveStorage::Blob destroy"
      return
    end

    super
  end

  def purge
    if EffectiveStorage.never_delete?
      Rails.logger.info "[effective_storage] Skipping ActiveStorage::Blob purge"
      return
    end

    super
  end

  def purge_later
    if EffectiveStorage.never_delete?
      Rails.logger.info "[effective_storage] Skipping ActiveStorage::Blob purge_later"
      return
    end

    super
  end

end
