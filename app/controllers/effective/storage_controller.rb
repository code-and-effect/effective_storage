module Effective
  class StorageController < ApplicationController
    include Effective::CrudController

    resource_scope -> { ActiveStorage::Blob.all }

    before_action(if: -> { params.key?(:id) }) do
      @blob = ActiveStorage::Blob.find_signed(params[:id])
    end

  end
end
