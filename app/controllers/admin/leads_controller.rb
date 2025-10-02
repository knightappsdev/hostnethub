class Admin::LeadsController < Admin::BaseController
  before_action :set_lead, only: [:show, :edit, :update, :destroy]

  def index
    @leads = Lead.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @lead = Lead.new
  end

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      redirect_to admin_lead_path(@lead), notice: 'Lead was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @lead.update(lead_params)
      redirect_to admin_lead_path(@lead), notice: 'Lead was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy
    redirect_to admin_leads_path, notice: 'Lead was successfully deleted.'
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(:first_name, :last_name, :email, :phone, :company, :website, :source, :status, :lifecycle_stage, :lead_score, :notes, :assigned_to_id, :user_id)
  end
end
