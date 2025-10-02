class Crm::LeadsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_lead, only: [:show, :edit, :update, :destroy, :convert_to_contact]

  def index
    @leads = Lead.includes(:assigned_to, :activities, :notes, :tasks)
    
    # Filter by status
    @leads = @leads.by_status(params[:status]) if params[:status].present?
    
    # Filter by lifecycle stage
    @leads = @leads.by_lifecycle_stage(params[:lifecycle_stage]) if params[:lifecycle_stage].present?
    
    # Filter by assigned user
    @leads = @leads.by_assigned_user(params[:assigned_to_id]) if params[:assigned_to_id].present?
    
    # Filter by score range
    if params[:min_score].present?
      @leads = @leads.where('lead_score >= ?', params[:min_score])
    end
    if params[:max_score].present?
      @leads = @leads.where('lead_score <= ?', params[:max_score])
    end
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @leads = @leads.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR company ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end
    
    # Ordering
    case params[:sort]
    when 'score_desc'
      @leads = @leads.order(lead_score: :desc)
    when 'score_asc'
      @leads = @leads.order(lead_score: :asc)
    when 'name'
      @leads = @leads.order(:first_name, :last_name)
    when 'company'
      @leads = @leads.order(:company)
    else
      @leads = @leads.recent
    end
    
    @leads = @leads.page(params[:page]).per(20)
    
    # For filter dropdowns
    @status_options = Lead.distinct.pluck(:status).compact
    @lifecycle_stage_options = Lead.distinct.pluck(:lifecycle_stage).compact
    @assigned_users = User.joins('JOIN leads ON leads.assigned_to_id = users.id').distinct
  end

  def show
    @activities = @lead.activities.recent.limit(10)
    @notes = @lead.notes.recent.limit(5)
    @tasks = @lead.tasks.pending.limit(5)
    @new_activity = @lead.activities.build
    @new_note = @lead.notes.build
    @new_task = @lead.tasks.build
  end

  def new
    @lead = Lead.new
    @users = User.all
  end

  def create
    @lead = Lead.new(lead_params)
    @lead.user = current_user unless @lead.user_id.present?
    
    if @lead.save
      # Log creation activity
      @lead.activities.create!(
        activity_type: 'lead_created',
        description: "Lead created by #{current_user.email}",
        user: current_user
      )
      
      redirect_to crm_lead_path(@lead), notice: 'Lead was successfully created.'
    else
      @users = User.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.all
  end

  def update
    old_stage = @lead.lifecycle_stage
    old_status = @lead.status
    
    if @lead.update(lead_params)
      # Log stage change activity
      if @lead.lifecycle_stage != old_stage
        @lead.activities.create!(
          activity_type: 'stage_changed',
          description: "Lifecycle stage changed from #{old_stage} to #{@lead.lifecycle_stage}",
          user: current_user
        )
      end
      
      # Log status change activity
      if @lead.status != old_status
        @lead.activities.create!(
          activity_type: 'status_changed',
          description: "Status changed from #{old_status} to #{@lead.status}",
          user: current_user
        )
      end
      
      redirect_to crm_lead_path(@lead), notice: 'Lead was successfully updated.'
    else
      @users = User.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lead.destroy
    redirect_to crm_leads_path, notice: 'Lead was successfully deleted.'
  end
  
  def convert_to_contact
    begin
      contact = @lead.convert_to_contact!
      
      # Log conversion activity
      @lead.activities.create!(
        activity_type: 'converted_to_contact',
        description: "Lead converted to contact by #{current_user.email}",
        user: current_user
      )
      
      redirect_to crm_contact_path(contact), notice: 'Lead successfully converted to contact.'
    rescue => e
      redirect_to crm_lead_path(@lead), alert: "Failed to convert lead: #{e.message}"
    end
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def lead_params
    params.require(:lead).permit(
      :first_name, :last_name, :email, :phone, :company, :website,
      :lifecycle_stage, :status, :source, :assigned_to_id, :lead_score,
      :job_title, :industry, :annual_revenue, :number_of_employees,
      :street_address, :city, :state, :postal_code, :country
    )
  end
end
