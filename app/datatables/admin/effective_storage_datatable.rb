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

      col :filename, label: 'File' do |attachment|
        content_tag(:div, class: 'col-resource_item') do
          link_to(attachment.blob.filename, url_for(attachment.blob), target: '_blank')
        end
      end

      col :permission, search: Effective::ActiveStorageExtension::PERMISSIONS do |attachment|
        if attachment.permission_public?
          content_tag(:span, attachment.permission, class: 'badge badge-warning')
        else
          content_tag(:span, attachment.permission, class: 'badge badge-info')
        end
      end

      col :content_type do |attachment|
        attachment.blob.content_type
      end

      col :byte_size do |attachment|
        number_to_human_size(attachment.blob.byte_size)
      end

      actions_col partial: 'admin/storage/datatable_actions', partial_as: :attachment
    end

    collection do
      ActiveStorage::Attachment.all.deep
    end

  end

end
