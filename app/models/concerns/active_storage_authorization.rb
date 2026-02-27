# frozen_string_literal: true

# This authorizes all ActiveStorage downloads
# This is included automatically by the engine
# It can be disabled by setting config.authorize_active_storage = false in config/initializers/effective_storage.rb
#
# There are 3 ways to add permissions:
# 1.) can?(:show, resource)
# 2.) can?(:show, ActionText::RichText) { |text| ... }
# 3.) can?(:show, ActiveStorage::Attachment) { |attachment| ... }
#
# The :show and :edit will both work.
#
module ActiveStorageAuthorization
  extend ActiveSupport::Concern

  AUTHORIZED_EFFECTIVE_DOWNLOADS = Set.new([
    'Effective::CarouselItem',
    'Effective::PageBanner',
    'Effective::PageSection',
    'Effective::Permalink'
  ]).freeze

  included do
    rescue_from(Effective::UnauthorizedStorageException, with: :unauthorized_active_storage_request)
  end

  # Authorize ActiveStorage DiskController downloads
  # Used for local storage
  def authorize_active_storage_download!
    @blob || set_download_blob()
    authorize_active_storage!
  end

  # Authorize ActiveStorage Blob and Representation redirects
  # Used for amazon storage
  def authorize_active_storage_redirect!
    @blob || set_blob()
    authorize_active_storage!
  end

  # Send an ExceptionNotification email with the unauthorized details
  # This is not visible to users
  def unauthorized_active_storage_request(exception)
    EffectiveResources.send_error(exception, current_user_id: (current_user&.id || 'none'))
  end

  private

  def set_download_blob
    @blob ||= ActiveStorage::Blob.includes(:attachments, :active_storage_extensions).where(key: decode_verified_key().try(:dig, :key)).first
  end

  # Authorize the current blob and prevent it from being served if unauthorized
  def authorize_active_storage!
    return unless @blob.present?

    # Disable strict loading and let the @blob just pull :attachments
    @blob.strict_loading!(false) if @blob.try(:strict_loading?)

    # If the blob is not attached to anything, permit the blob
    return true if @blob.attachments.blank?

    # If the blob is an ActiveStorage::Variant it's been previously authorized
    return true if @blob.attachments.any? { |attachment| authorized_variant_download?(attachment) }

    # If the blob is a known good effective class fast path it
    return true if @blob.attachments.any? { |attachment| authorized_effective_download?(attachment) }

    # If the blob has been marked public, permit the download (in-memory check, no queries)
    return true if @blob.permission_public?

    # If we are authorized on any attached record, permit the download
    return true if @blob.attachments.any? { |attachment| authorized_attachment_download?(attachment) }

    # Otherwise raise a 404 Not Found and block the download
    head(:not_found)

    # Raise an exception to log unauthorized request
    raise_exception()
  end

  def raise_exception
    attachment = @blob.attachments.first
    record = attachment.record if attachment
    resource = record.record if record.respond_to?(:record)

    return if skip_notification?(record || resource || @blob)

    error = [
      "unauthorized active storage request for #{@blob.filename}",
      ("on #{record.class.name} #{record.id}" if record.present?),
      ("from #{resource.class.name} #{resource.id}" if resource.present?),
      ("with current_user #{current_user.class.name } #{current_user&.id}"),
    ].compact.join(' ')

    resolution = "Missing can?(:show, #{(resource || record || attachment).class.name})"

    raise Effective::UnauthorizedStorageException.new(error + '. ' + resolution)
  end

  def skip_notification?(resource)
    return true if EffectiveStorage.skip_notification?
    return true if EffectiveStorage.skip_notifications.include?(resource.class.name)
    return true if request.referer.to_s.include?('.test:')

    false
  end

  # This was included and resized in an ActionText::RichText object
  # But these ones don't belong_to any record
  def authorized_variant_download?(attachment)
    attachment.record_type == 'ActiveStorage::VariantRecord'
  end

  # These are always public images
  # Fast path them so we don't have to load any user for a permission check
  def authorized_effective_download?(attachment)
    AUTHORIZED_EFFECTIVE_DOWNLOADS.include?(attachment.record_type)
  end

  # This is a has_one_attached or has_many_attached record
  # Or an ActionText::RichText object, that belongs_to a record
  def authorized_attachment_download?(attachment)
    return false if attachment.record_type.blank?

    # Attachment itself
    return true if EffectiveResources.authorized?(self, :show, attachment)

    # DO NOT USE .blank? or .present? here. They return incorrect values.
    return false if attachment.record.nil?

    record = attachment.record
    return true if authorized?(record)

    # ActionText::RichText
    resource = record.record if record.respond_to?(:record)
    return true if authorized?(resource)

    false
  end

  def authorized?(record)
    return false if record.blank?

    # If they can show or edit the resource, they are authorized.
    return true if EffectiveResources.authorized?(self, :show, record)
    return true if EffectiveResources.authorized?(self, :edit, record)

    false
  end

  def current_user
    (defined?(Tenant) ? send("current_#{Tenant.current}_user") : super)
  end

  def current_ability
    @current_ability ||= (defined?(Tenant) ? Tenant.Ability.new(current_user) : super)
  end

end
