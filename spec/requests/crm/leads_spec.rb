require 'rails_helper'

RSpec.describe "Crm/leads", type: :request do

  let(:user) { create(:user) }
  before { sign_in_as(user) }

  describe "GET /crm/leads" do
    it "returns http success" do
      get crm_leads_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /crm/leads/:id" do
    let(:lead) { create(:lead, user: user) }


    it "returns http success" do
      get crm_lead_path(lead)
      expect(response).to be_success_with_view_check('show')
    end
  end

  describe "GET /crm/leads/new" do
    it "returns http success" do
      get new_crm_lead_path
      expect(response).to be_success_with_view_check('new')
    end
  end
  
  describe "GET /crm/leads/:id/edit" do
    let(:lead) { create(:lead, user: user) }


    it "returns http success" do
      get edit_crm_lead_path(lead)
      expect(response).to be_success_with_view_check('edit')
    end
  end
end
