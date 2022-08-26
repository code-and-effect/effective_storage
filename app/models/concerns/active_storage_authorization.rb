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

  included do
    rescue_from(Exception, with: :unauthorized_active_storage_request)
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
    return if request.referer.to_s.include?('.test:')

    if defined?(ExceptionNotifier)
      data = { 'current_user_id': current_user&.id || 'none' }.merge(@blob&.attributes || {})
      ExceptionNotifier.notify_exception(exception, env: request.env, data: data)
    else
      raise(exception)
    end
  end

  private

  def set_download_blob
    @blob ||= ActiveStorage::Blob.where(key: decode_verified_key().try(:dig, :key)).first
  end

  # Authorize the current blob and prevent it from being served if unauthorized
  def authorize_active_storage!
    return unless @blob.present?

    # If the blob has been given permission
    return true if authorized?(@blob)

    # If the blob is not attached to anything, permit the blob
    return true if @blob.attachments.blank? && authorize_content_download?(@blob)

    # If the blob is an ActiveStorage::Variant it's been previously authorized
    return true if @blob.attachments.any? { |attachment| authorized_variant_download?(attachment) }

    # If we are authorized on any attached record, permit the download
    return true if @blob.attachments.any? { |attachment| authorized_attachment_download?(attachment) }

    # Otherwise raise a 403 Forbidden and block the download
    head :forbidden

    # Raise an exception to log unauthorized request
    raise_exception()
  end

  def raise_exception
    attachment = @blob.attachments.first
    record = attachment.record if attachment
    resource = record.record if record.respond_to?(:record)

    error = [
      "unauthorized active storage request for #{@blob.filename}",
      ("on #{record.class.name} #{record.id}" if record.present?),
      ("from #{resource.class.name} #{resource.id}" if resource.present?),
      ("with current_user #{current_user.class.name } #{current_user&.id}"),
    ].compact.join(' ')

    resolution = "Missing can?(:show, #{(resource || record || attachment).class.name})"

    raise(error + '. ' + resolution)
  end

  # This is a file that was drag & drop or inserted into the article editor
  # I think this might only happen with article editor edit screens
  def authorize_content_download?(blob)
    # Allow signed out users to view images
    return true if blob.image?

    # Require sign in to view any attached files
    current_user.present?
  end

  # This was included and resized in an ActionText::RichText object
  # But these ones don't belong_to any record
  def authorized_variant_download?(attachment)
    attachment.record_type == 'ActiveStorage::VariantRecord'
  end

  # This is a has_one_attached or has_many_attached record
  # Or an ActionText::RichText object, that belongs_to a record
  def authorized_attachment_download?(attachment)
    return false if attachment.record.blank?

    # Associated Record
    record = attachment.record
    return true if authorized?(record)

    # ActionText::RichText
    resource = record.record if record.respond_to?(:record)
    return true if authorized?(resource)

    # Attachment itself
    return true if authorized?(attachment)

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
