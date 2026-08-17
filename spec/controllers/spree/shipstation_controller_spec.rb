# frozen_string_literal: true

RSpec.describe(Spree::ShipstationController) do
  render_views

  let!(:store) { create(:store, default: true) }
  let!(:ssi) { create(:shipstation_integration) }
  let(:inactive_integration) { instance_double(Spree::Integrations::Shipstation, active?: false) }

  describe "#export" do
    context "when the integration is present, but not activated" do
      before do
        allow(controller).to receive(:store_integration).with("shipstation").and_return(inactive_integration)
      end

      it("returns a 404") do
        get :export, params: {format: :xml}
        expect(response.status).to eq(404)
      end
    end

    context "when the authentication is invalid" do
      it("returns 401") do
        stub_basic_auth("some_wrong_username", "not_the_correct-password")
        create(:order_ready_to_ship, store: store)

        get :export, params: {format: :xml}
        expect(response.status).to eq(401)
      end
    end

    context "when the authentication is valid" do
      before do
        stub_basic_auth(ssi.preferred_username, ssi.preferred_password)
        create(:order_ready_to_ship, store: store)
      end

      it("responds with 200 OK") do
        get :export,
          params: {
            start_date: 1.day.ago.strftime("%m/%d/%Y %H:%M"),
            end_date: 1.day.from_now.strftime("%m/%d/%Y %H:%M"),
            format: :xml,
            page: 1
          }

        expect(response.status).to eq(200)
      end

      it("generates ShipStation-compliant XML") do
        get :export,
          params: {
            start_date: 100.day.ago.strftime("%m/%d/%Y %H:%M"),
            end_date: 2.day.from_now.strftime("%m/%d/%Y %H:%M"),
            format: :xml,
            page: 1
          }

        expect(response.body).to pass_validation("spec/fixtures/shipstation_xml_schema.xsd")
      end

      it("ignores malformed date params") do
        get :export, params: {start_date: "not-a-date", end_date: "13/45/9999", format: :xml, page: 1}

        expect(response.status).to eq(200)
      end

      it("still emits valid XML when date params are malformed") do
        get :export, params: {start_date: "not-a-date", end_date: "13/45/9999", format: :xml, page: 1}

        expect(response.body).to pass_validation("spec/fixtures/shipstation_xml_schema.xsd")
      end
    end
  end

  describe "#shipnotify" do
    context "when the integration is present, but not activated" do
      before do
        allow(controller).to receive(:store_integration).with("shipstation").and_return(inactive_integration)
      end

      it("returns 404") do
        post :shipnotify, params: {
          order_number: "123456",
          tracking_number: "123456",
          format: :xml
        }
        expect(response.status).to eq(404)
      end
    end

    context "when the authentication is invalid" do
      it("returns 401") do
        post :shipnotify, params: {
          order_number: "12334523",
          tracking_number: "123456",
          format: :xml
        }
        expect(response.status).to eq(401)
      end
    end

    context "when the authentication is valid" do
      before do
        stub_basic_auth(ssi.preferred_username, ssi.preferred_password)
      end

      context "when the shipment can be found" do
        let(:shipment) { create(:order_ready_to_ship).shipments.first }

        it("responds with 200 OK") do
          post :shipnotify, params: {
            order_number: shipment.number,
            tracking_number: "123456",
            format: :xml
          }

          expect(response.status).to eq(200)
        end

        it("updates the shipment") do
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

        it("responds with 400 Bad Request when the tracking number is missing") do
          post :shipnotify, params: {
            order_number: shipment.number,
            format: :xml
          }

          expect(response.status).to eq(400)
        end

        it("does not ship when the tracking number is missing") do
          post :shipnotify, params: {
            order_number: shipment.number,
            format: :xml
          }

          expect(shipment.reload).not_to be_shipped
        end
      end

      context "when the shipment cannot be found" do
        it("responds with 400 Bad Request") do
          create(:order_ready_to_ship)

          post :shipnotify, params: {
            order_number: "ABC123",
            tracking_number: "123456",
            format: :xml
          }

          expect(response.status).to eq(400)
        end
      end
    end
  end
end
