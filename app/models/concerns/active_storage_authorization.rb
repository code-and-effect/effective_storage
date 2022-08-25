# frozen_string_literal: true

# This is included by upside config/initializers/active_storage_authorization.rb
# If you want to turn this off, best to do it there.
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
    Rails.logger.info "===== Authorizing Active Storage Download"

    @blob || set_download_blob()
    authorize_active_storage!
  end

  # Authorize ActiveStorage Blob and Representation redirects
  # Used for amazon storage
  def authorize_active_storage_redirect!
    Rails.logger.info "===== Authorizing Active Storage Redirect"

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

  # Authorize the current blob and prevent it from being served if unauthorized
  def authorize_active_storage!
    return unless @blob.present?

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
  # This isn't currently used in upside, but will be "one day"
  def authorize_content_download?(blob)
    Rails.logger.info "===== authorize content download?"

    # Allow signed out users to view images
    # return true if blob.image?

    # Require sign in to view any attached files
    # current_user.present?

    # Allow public users
    true
  end

  # This was included and resized in an ActionText::RichText object
  # But these ones don't belong_to any record
  def authorized_variant_download?(attachment)
    Rails.logger.info "===== authorize variant download?"

    attachment.record_type == 'ActiveStorage::VariantRecord'
  end

  # This is a has_one_attached or has_many_attached record
  # Or an ActionText::RichText object, that belongs_to a record
  def authorized_attachment_download?(attachment)
    Rails.logger.info "===== authorize attachment download?"

    return false if attachment.record.blank?

    record = attachment.record
    return true if authorized?(record)

    resource = record.record if record.respond_to?(:record)
    return true if authorized?(resource)

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

  def set_download_blob
    @blob ||= ActiveStorage::Blob.where(key: decode_verified_key().try(:dig, :key)).first
  end

  def current_user
    defined?(Tenant) ? send("current_#{Tenant.current}_user") : super()
  end

  def current_ability
    @current_ability ||= begin
      defined?(tenant) ? Tenant.Ability.new(current_user) : Ability.new(current_user)
    end
  end

end
