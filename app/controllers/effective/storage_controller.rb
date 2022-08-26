module Effective
  class StorageController < ApplicationController
    include Effective::CrudController

    resource_scope -> { ActiveStorage::Attachment.all }

    # def mark_public
    #   @attachment = ActiveStorage::Attachment.
    # end

    # # Confirms an order from the cart.
    # def create
    #   @order ||= Effective::Order.new(view_context.current_cart)
    #   EffectiveResources.authorize!(self, :create, @order)

    #   @order.assign_attributes(checkout_params)

    #   if (@order.confirm! rescue false)
    #     redirect_to(effective_orders.order_path(@order))
    #   else
    #     flash.now[:danger] = "Unable to proceed: #{flash_errors(@order)}. Please try again."
    #     render :new
    #   end
    # end

  end
end
