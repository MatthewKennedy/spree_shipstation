require 'spec_helper'

RSpec.describe SpreeShipstation do
  describe 'VERSION' do
    it 'is defined' do
      expect(SpreeShipstation::VERSION).to be_present
    end
  end
end
