class Admin::ActivitiesController < Admin::BaseController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  def index
    @activities = Activity.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @activity = Activity.new
  end

  def create
    @activity = Activity.new(activity_params)

    if @activity.save
      redirect_to admin_activity_path(@activity), notice: 'Activity was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @activity.update(activity_params)
      redirect_to admin_activity_path(@activity), notice: 'Activity was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to admin_activities_path, notice: 'Activity was successfully deleted.'
  end

  private

  def set_activity
    @activity = Activity.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(:activity_type, :title, :description, :activity_date, :contact_id, :lead_id, :deal_id, :user_id)
  end
end
