require 'rails_helper'

RSpec.describe "Crm/contacts", type: :request do

  let(:user) { create(:user) }
  before { sign_in_as(user) }

  describe "GET /crm/contacts" do
    it "returns http success" do
      get crm_contacts_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /crm/contacts/:id" do
    let(:contact) { create(:contact, user: user) }


    it "returns http success" do
      get crm_contact_path(contact)
      expect(response).to be_success_with_view_check('show')
    end
  end

  describe "GET /crm/contacts/new" do
    it "returns http success" do
      get new_crm_contact_path
      expect(response).to be_success_with_view_check('new')
    end
  end
  
  describe "GET /crm/contacts/:id/edit" do
    let(:contact) { create(:contact, user: user) }


    it "returns http success" do
      get edit_crm_contact_path(contact)
      expect(response).to be_success_with_view_check('edit')
    end
  end
end
