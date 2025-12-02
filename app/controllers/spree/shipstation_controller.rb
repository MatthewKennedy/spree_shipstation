# frozen_string_literal: true

module Spree
  class ShipstationController < Spree::BaseController
    include Spree::IntegrationsHelper

    protect_from_forgery with: :null_session, only: :shipnotify

    before_action :ensure_active_integration
    before_action :authenticate_shipstation

    def export
      @shipments = current_store.shipments
        .exportable
        .includes(
          :order,
          inventory_units: {
            line_item: {
              variant: [
                :product,
                :images,
                { option_values: :option_type }
              ]
            }
          }
        )
        .between(date_param(:start_date), date_param(:end_date))
        .page(params[:page])
        .per(50)

      respond_to do |format|
        format.xml { render layout: false }
      end
    end

    def shipnotify
      SpreeShipstation::ShipmentNotice.from_payload(params.to_unsafe_h).apply
      head :ok
    rescue SpreeShipstation::Error => e
      Rails.logger.error("ShipStation Notification Error: #{e.message}")
      head :bad_request
    end

    private

    def ensure_active_integration
      unless store_integration('shipstation')&.active?
        head :not_found
      end
    end

    def date_param(name)
      return if params[name].blank?

      Time.strptime("#{params[name]} UTC", "%m/%d/%Y %H:%M %Z")
    rescue ArgumentError
      nil
    end

    def authenticate_shipstation
      authenticate_or_request_with_http_basic do |username, password|
        username == store_integration('shipstation').preferred_username &&
          password == store_integration('shipstation').preferred_password
      end
    end
  end
end
