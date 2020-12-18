# frozen_string_literal: true

module Spree
  class ShipstationController < Spree::BaseController
    protect_from_forgery with: :null_session, only: :shipnotify

    before_action :authenticate_shipstation

    def export
      @shipments = Spree::Shipment
        .exportable
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
    rescue SpreeShipstation::Error
      head :bad_request
    end

    private

    def date_param(name)
      return if params[name].blank?

      Time.strptime("#{params[name]} UTC", "%m/%d/%Y %H:%M %Z")
    end

    def authenticate_shipstation
      authenticate_or_request_with_http_basic do |username, password|
        username == SpreeShipstation.configuration.username &&
          password == SpreeShipstation.configuration.password
      end
    end
  end
end
