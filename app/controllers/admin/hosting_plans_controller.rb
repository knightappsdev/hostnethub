class Admin::HostingPlansController < Admin::BaseController
  before_action :set_hosting_plan, only: [:show, :edit, :update, :destroy]

  def index
    @hosting_plans = HostingPlan.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @hosting_plan = HostingPlan.new
  end

  def create
    @hosting_plan = HostingPlan.new(hosting_plan_params)

    if @hosting_plan.save
      redirect_to admin_hosting_plan_path(@hosting_plan), notice: 'Hosting plan was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @hosting_plan.update(hosting_plan_params)
      redirect_to admin_hosting_plan_path(@hosting_plan), notice: 'Hosting plan was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @hosting_plan.destroy
    redirect_to admin_hosting_plans_path, notice: 'Hosting plan was successfully deleted.'
  end

  private

  def set_hosting_plan
    @hosting_plan = HostingPlan.find(params[:id])
  end

  def hosting_plan_params
    params.require(:hosting_plan).permit(:name, :description, :price_monthly, :websites_limit, :storage_gb, :bandwidth_gb, :email_marketing, :seo_tools, :social_scheduler, :migration_support, :featured, :active)
  end
end
