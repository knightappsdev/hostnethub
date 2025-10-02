require 'rails_helper'

RSpec.describe "Crm/dashboards", type: :request do

  let(:user) { create(:user) }
  before { sign_in_as(user) }

  describe "GET /crm/dashboards" do
    it "returns http success" do
      get crm_dashboards_path
      expect(response).to be_success_with_view_check('index')
    end
  end



end
