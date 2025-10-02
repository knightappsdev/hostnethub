class HostingPlansController < ApplicationController

  def index
    @hosting_plans = HostingPlan.active.by_price
    @featured_plan = HostingPlan.featured.first
  end

  def show
    @hosting_plan = HostingPlan.find(params[:id])
  end

  private
  
  def hosting_plan_params
    params.require(:hosting_plan).permit(:name, :description, :price_monthly, :websites_limit, :storage_gb, :bandwidth_gb, :email_marketing, :seo_tools, :social_scheduler, :migration_support)
  end
end
