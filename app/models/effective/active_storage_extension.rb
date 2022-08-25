module Effective
  class ActiveStorageExtension < ActiveRecord::Base
    belongs_to :attachment, class_name: 'ActiveStorage::Attachment'

    PERMISSIONS = ['inherited', 'public']

    effective_resource do
      permission :string

      timestamps
    end

    scope :deep, -> { includes(:attachment) }
    scope :sorted, -> { order(:id) }

    validates :permission, presence: true, inclusion: { in: PERMISSIONS }

    def to_s
      permission.presence || 'active storage extension'
    end

    def permission_inherited?
      permission == 'inherited'
    end

    def permission_public?
      permission == 'public'
    end

  end
end
