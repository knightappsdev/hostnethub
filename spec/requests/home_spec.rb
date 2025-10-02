require 'rails_helper'

# IMPORTANT: Demo File Management in Tests
# - If app/views/shared/demo.html.erb exists but app/views/home/index.html.erb exists,
#   demo.html.erb should be deleted immediately as it's only for early development
# - Tests should verify real homepage functionality, not demo placeholder content
# - Demo contains fake data and should not be referenced in production feature tests

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to be_success_with_view_check('index')
    end

    it "should not have demo.html.erb when home/index.html.erb exists" do
      index_template_path = Rails.root.join('app', 'views', 'home', 'index.html.erb')
      demo_template_path = Rails.root.join('app', 'views', 'shared', 'demo.html.erb')
      
      if File.exist?(index_template_path)
        expect(File.exist?(demo_template_path)).to be_falsey, 
          "Demo file should be deleted when real homepage exists. Found both #{index_template_path} and #{demo_template_path}"
      end
    end
  end
end
