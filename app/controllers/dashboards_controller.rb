class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = Current.user
    @orders = @user.orders.recent.limit(10)
    @active_orders = @user.orders.paid
    @hosting_plans = HostingPlan.active.limit(3)
    
    # Calculate user statistics
    @total_orders = @user.orders.count
    @total_spent = @user.orders.paid.sum(:amount)
    @active_services = @user.orders.paid.count
  end

  private
  # Write your private methods here
end
