module Effective
  class ActiveStorageExtension < ActiveRecord::Base
    belongs_to :blob, class_name: 'ActiveStorage::Blob'

    PERMISSIONS = ['public', 'restricted']

    effective_resource do
      permission :string

      timestamps
    end

    scope :deep, -> { includes(blob: :attachments) }
    scope :sorted, -> { order(:id) }

    validates :permission, presence: true

    def to_s
      permission.presence || 'active storage extension'
    end

  end
end
