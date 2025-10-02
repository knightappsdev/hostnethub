class HomeController < ApplicationController
  include HomeDemoConcern

  def index
    @hosting_plans = HostingPlan.active.by_price.limit(3)
    @featured_plan = HostingPlan.featured.first
  end
end
