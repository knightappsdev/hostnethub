require 'rails_helper'

RSpec.describe "Admin::Tasks", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/tasks" do
    it "returns http success" do
      get admin_tasks_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
