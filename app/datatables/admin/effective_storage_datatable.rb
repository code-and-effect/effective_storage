module Admin
  class EffectiveStorageDatatable < Effective::Datatable
    datatable do
      order :created_at

      col :created_at, as: :date
      col :updated_at, visible: false
      col :id, visible: false

      col :record_type, visible: false
      col :record_id, label: 'Record Id', visible: false

      col :related_type, visible: false do |attachment|
        attachment.record.try(:record_type)
      end

      col :related_id, label: 'Related Id', visible: false do |attachment|
        attachment.record.try(:record_id)
      end

      col :resource_type do |attachment|
        attachment.record.try(:record_type) || attachment.record_type
      end

      col :resource do |attachment|
        record = attachment.record
        record = attachment.record.record if record.respond_to?(:record) # ActionText::RichText will

        url = Effective::Resource.new(record, namespace: :admin).action_path(:edit)
        link_to(record, url, target: '_blank') if url
      end

      col 'blob.filename' do |attachment|
        content_tag(:div, class: 'col-resource_item') do
          link_to(attachment.blob.filename, url_for(attachment.blob), target: '_blank')
        end
      end

      col 'blob.content_type'

      col 'blob.byte_size' do |attachment|
        number_to_human_size(attachment.blob.byte_size)
      end

      actions_col

      # actions_col(destroy: false) do |attachment|
      #   if can?(:destroy, attachment)
      #     dropdown_link_to('Delete', admin_attachment_path(attachment), data: { method: :delete, confirm: "Really delete #{attachment.blob.filename}?"})
      #   end
      # end

    end

    # If we're passed a user_id, we want all the Attachments for this user
    # Accross all applicants
    collection do
      attachments = ActiveStorage::Attachment.all.joins(:blob)
      attachments
    end

  end

end
