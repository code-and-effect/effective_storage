module Admin
  class EffectiveStorageDatatable < Effective::Datatable
    filters do
      scope :all
      scope :attached
      scope :unattached
    end

    datatable do
      col :created_at, as: :date

      col :id, visible: false
      col :key, visible: false

      col :record_type, visible: false do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, attachment.record_type, class: 'col-resource_item')
        end.join.html_safe
      end

      col :record_id, visible: false do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, attachment.record_id, class: 'col-resource_item')
        end.join.html_safe
      end

      col :related_type, visible: false do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, attachment.record.try(:record_type), class: 'col-resource_item')
        end.join.html_safe
      end

      col :related_id, visible: false, label: 'Related Id' do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, attachment.record.try(:record_id), class: 'col-resource_item')
        end.join.html_safe
      end

      col :resource_type do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, class: 'col-resource_item') do
            (attachment.record.try(:record_type) || attachment.record_type)
          end
        end.join.html_safe
      end

      col :resource do |blob|
        blob.attachments.map do |attachment|
          content_tag(:div, class: 'col-resource_item') do
            record = attachment.record
            record = attachment.record.record if record.respond_to?(:record) # ActionText::RichText will

            url = Effective::Resource.new(record, namespace: :admin).action_path(:edit)
            link_to(record, url, target: '_blank') if url
          end
        end.join.html_safe
      end

      col :filename, label: 'File' do |blob|
        content_tag(:div, class: 'col-resource_item') do
          link_to(blob.filename, url_for(blob), target: '_blank')
        end
      end

      col :permission, search: Effective::ActiveStorageExtension::PERMISSIONS do |blob|
        if blob.permission_public?
          content_tag(:span, blob.permission, class: 'badge badge-warning')
        else
          content_tag(:span, blob.permission, class: 'badge badge-info')
        end
      end

      col :content_type

      col :byte_size do |blob|
        number_to_human_size(blob.byte_size)
      end

      actions_col partial: 'admin/storage/datatable_actions', partial_as: :blob
    end

    collection do
      ActiveStorage::Blob.all.deep.left_outer_joins(:attachments)
    end

  end

end
