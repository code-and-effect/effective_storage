module Admin
  class StorageController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_storage) }

    include Effective::CrudController

    page_title 'Storage'

    resource_scope -> { ActiveStorage::Attachment.all }
    datatable -> { Admin::EffectiveStorageDatatable.new }

    private

    def permitted_params
      params.require(:active_storage_extension).permit!
    end

  end
end
