require 'rails_helper'

RSpec.describe "Hosting plans", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { create(:user) }
  # before { sign_in_as(user) }

  describe "GET /hosting_plans" do
    it "returns http success" do
      get hosting_plans_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /hosting_plans/:id" do
    let(:hosting_plan) { create(:hosting_plan) }


    it "returns http success" do
      get hosting_plan_path(hosting_plan)
      expect(response).to be_success_with_view_check('show')
    end
  end


end
