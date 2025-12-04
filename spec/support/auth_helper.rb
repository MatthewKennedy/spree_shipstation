module AuthHelper
  def stub_basic_auth(username, password)
    request.headers["Authorization"] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :controller
end
