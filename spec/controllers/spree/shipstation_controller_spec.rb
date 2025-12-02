RSpec.describe Spree::ShipstationController do
  render_views

  let!(:store) { create(:store, default: true) }
  let(:inactive_integration) { instance_double("Spree::Integration::Shipstation", active?: false) }

  describe "#export" do
    before do
      create(:shipstation_integration)
    end

    context "when the integration is present, but not activated" do
      before do
        allow(controller).to receive(:store_integration).with('shipstation').and_return(inactive_integration)
      end

      it "returns a 404" do
        get :export, params: { format: :xml }

        expect(response.status).to eq(404)
      end
    end

    context "when the authentication is invalid" do
      it "returns 401" do
        stub_shipstation_auth('some_wrong_username', 'not_the_correct-password')
        create(:order_ready_to_ship, store: store)

        get :export, params: {format: :xml}

        expect(response.status).to eq(401)
      end
    end

    context "when the authentication is valid" do
      it "responds with 200 OK" do
        stub_shipstation_auth
        create(:order_ready_to_ship, store: store)

        get :export,
          params: {
            start_date: 1.day.ago.strftime("%m/%d/%Y %H:%M"),
            end_date: 1.day.from_now.strftime("%m/%d/%Y %H:%M"),
            format: :xml,
            page: 1
          }

        expect(response.status).to eq(200)
      end

      it "generates ShipStation-compliant XML" do
        stub_shipstation_auth
        create(:order_ready_to_ship, store: store)

        get :export,
          params: {
            start_date: 100.day.ago.strftime("%m/%d/%Y %H:%M"),
            end_date: 2.day.from_now.strftime("%m/%d/%Y %H:%M"),
            format: :xml,
            page: 1
          }

        expect(response.body).to pass_validation("spec/fixtures/shipstation_xml_schema.xsd")
      end
    end
  end

  describe "#shipnotify" do
    before do
      create(:shipstation_integration)
    end

    context "when the integration is present, but not activated" do
      before do
        allow(controller).to receive(:store_integration).with('shipstation').and_return(inactive_integration)
      end

      it "returns 404" do
        post :shipnotify, params: {
          order_number: "123456",
          tracking_number: "123456",
          format: :xml
        }

        expect(response.status).to eq(404)
      end
    end

    context "when the authentication is invalid" do
      it "returns 401" do
        post :shipnotify, params: {
          order_number: "12334523",
          tracking_number: "123456",
          format: :xml
        }

        expect(response.status).to eq(401)
      end
    end

    context "when the authentication is valid" do
      context "when the shipment can be found" do
        it "responds with 200 OK" do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: shipment.number,
            tracking_number: "123456",
            format: :xml
          }
          shipment.reload

          expect(response.status).to eq(200)
        end

        it "updates the shipment" do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: shipment.number,
            tracking_number: "123456",
            format: :xml
          }
          shipment.reload

          expect(shipment).to have_attributes(
            tracking: "123456",
            state: "shipped",
            shipped_at: an_instance_of(ActiveSupport::TimeWithZone)
          )
        end
      end

      context "when the shipment cannot be found" do
        it "responds with 400 Bad Request" do
          stub_shipstation_auth
          shipment = create(:order_ready_to_ship).shipments.first

          post :shipnotify, params: {
            order_number: "ABC123",
            tracking_number: "123456",
            format: :xml
          }
          shipment.reload

          expect(response.status).to eq(400)
        end
      end
    end
  end

  def stub_shipstation_auth(username = "my_username", password = "1Password-123!")
    request.headers["Authorization"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
