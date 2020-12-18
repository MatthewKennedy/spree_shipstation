# frozen_string_literal: true

RSpec.describe Spree::ShipstationController do
  render_views

  describe '#export' do
    context 'when the authentication is invalid' do
      it 'returns an error error' do
        get :export, params: { format: 'xml' }

        expect(response.status).to eq(401)
      end
    end

    context 'when the authentication is valid' do
      it 'responds with 200 OK' do
        stub_shipstation_auth
        create(:order_ready_to_ship)

        get :export,
          params: {
            start_date: 1.day.ago.strftime('%m/%d/%Y %H:%M'),
            end_date: 1.day.from_now.strftime('%m/%d/%Y %H:%M'),
            format: 'xml'
          }

        expect(response.status).to eq(200)
      end

      it 'generates ShipStation-compliant XML' do
        stub_shipstation_auth
        create(:order_ready_to_ship)

        get :export, params: {
          start_date: 1.day.ago.strftime('%m/%d/%Y %H:%M'),
          end_date: 1.day.from_now.strftime('%m/%d/%Y %H:%M'),
          format: 'xml'
        }

        expect(response.body).to pass_validation('spec/fixtures/shipstation_xml_schema.xsd')
      end
    end
  end

  describe '#shipnotify' do
    context 'when the authentication is valid' do
      context 'when the shipment can be found' do
        it 'responds with 200 OK' do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: shipment.number,
            tracking_number: '123456',
            format: 'xml',
          }
          shipment.reload

          expect(response.status).to eq(200)
        end

        it 'updates the shipment' do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: shipment.number,
            tracking_number: '123456',
            format: 'xml',
          }
          shipment.reload

          expect(shipment).to have_attributes(
            tracking: '123456',
            state: 'shipped',
            shipped_at: an_instance_of(ActiveSupport::TimeWithZone),
          )
        end
      end

      context 'when the shipment cannot be found' do
        it 'responds with 400 Bad Request' do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: 'ABC123',
            tracking_number: '123456',
            format: 'xml',
          }
          shipment.reload

          expect(response.status).to eq(400)
        end
      end
    end
  end

  def stub_shipstation_auth(username = 'mario', password = 'lemieux')
    stub_configuration(username: username, password: password)
    request.headers['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
