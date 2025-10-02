require 'rails_helper'

RSpec.describe "Admin::HostingPlans", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/hosting_plans" do
    it "returns http success" do
      get admin_hosting_plans_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
