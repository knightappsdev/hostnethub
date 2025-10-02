class Crm::ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :create_deal, :create_activity, :create_note, :create_task]

  def index
    # Apply filters
    contacts = current_user.contacts
    contacts = contacts.by_lifecycle_stage(params[:lifecycle_stage]) if params[:lifecycle_stage].present?
    contacts = contacts.where(user: User.find(params[:user_id])) if params[:user_id].present?
    contacts = contacts.where('contact_score >= ?', params[:min_score]) if params[:min_score].present?
    contacts = contacts.where('contact_score <= ?', params[:max_score]) if params[:max_score].present?
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      contacts = contacts.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR company ILIKE ? OR phone ILIKE ?",
        search_term, search_term, search_term, search_term, search_term
      )
    end
    
    # Sorting
    case params[:sort]
    when 'name_asc'
      contacts = contacts.order(:first_name, :last_name)
    when 'name_desc'
      contacts = contacts.order(first_name: :desc, last_name: :desc)
    when 'score_asc'
      contacts = contacts.order(:contact_score)
    when 'score_desc'
      contacts = contacts.order(contact_score: :desc)
    when 'created_asc'
      contacts = contacts.order(:created_at)
    when 'created_desc'
      contacts = contacts.order(created_at: :desc)
    when 'last_activity'
      contacts = contacts.joins(:activities).group('contacts.id').order('MAX(activities.activity_date) DESC NULLS LAST')
    else
      contacts = contacts.order(created_at: :desc)
    end
    
    @contacts = contacts.page(params[:page]).per(20)
    
    # Statistics for dashboard
    @total_contacts = current_user.contacts.count
    @customers = current_user.contacts.customers.count
    @high_score_contacts = current_user.contacts.high_score.count
    @recent_contacts = current_user.contacts.where('created_at > ?', 7.days.ago).count
    @avg_score = current_user.contacts.average(:contact_score)&.round(1) || 0
    
    # Lifecycle stage breakdown
    @lifecycle_stats = current_user.contacts.group(:lifecycle_stage).count
    
    # Users for filter dropdown
    @users = User.joins(:contacts).distinct.order(:email)
    
    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  def show
    @activities = @contact.activities.order(activity_date: :desc).limit(10)
    @recent_notes = @contact.notes.order(created_at: :desc).limit(5)
    @active_tasks = @contact.tasks.where.not(status: 'completed').order(:due_date)
    @deals = @contact.deals.order(created_at: :desc)
    @interaction_timeline = build_interaction_timeline
    
    # Contact metrics
    @total_interactions = @contact.activities.count
    @total_deal_value = @contact.total_deal_value
    @active_deals_count = @contact.active_deals_count
    @days_since_last_contact = @contact.days_since_last_contact
  end

  def new
    @contact = current_user.contacts.build
    @contact.lifecycle_stage = 'subscriber'
  end

  def create
    @contact = current_user.contacts.build(contact_params)
    
    if @contact.save
      # Log contact creation activity
      @contact.activities.create!(
        user: current_user,
        activity_type: 'contact_created',
        subject: "Contact created: #{@contact.display_name}",
        activity_date: Time.current,
        description: "New contact added to the system"
      )
      
      flash[:success] = "Contact created successfully!"
      redirect_to crm_contact_path(@contact)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    old_stage = @contact.lifecycle_stage
    
    if @contact.update(contact_params)
      # Log stage change if it occurred
      if old_stage != @contact.lifecycle_stage
        @contact.activities.create!(
          user: current_user,
          activity_type: 'stage_change',
          subject: "Lifecycle stage changed from #{old_stage} to #{@contact.lifecycle_stage}",
          activity_date: Time.current,
          description: "Contact lifecycle stage updated"
        )
      end
      
      # General update activity
      @contact.activities.create!(
        user: current_user,
        activity_type: 'contact_updated',
        subject: "Contact updated: #{@contact.display_name}",
        activity_date: Time.current,
        description: "Contact information updated"
      )
      
      flash[:success] = "Contact updated successfully!"
      redirect_to crm_contact_path(@contact)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy!
    flash[:success] = "Contact deleted successfully!"
    redirect_to crm_contacts_path
  end

  # Quick actions for contact interaction
  def create_deal
    @deal = @contact.deals.build(
      user: current_user,
      deal_name: params[:deal_name],
      amount: params[:amount],
      stage: 'prospecting',
      expected_close_date: params[:expected_close_date]
    )
    
    if @deal.save
      # Log deal creation activity
      @contact.activities.create!(
        user: current_user,
        activity_type: 'deal_created',
        subject: "New deal created: #{@deal.deal_name}",
        activity_date: Time.current,
        description: "Deal created with amount: #{@deal.amount}"
      )
      
      flash[:success] = "Deal created successfully!"
    else
      flash[:error] = "Failed to create deal: #{@deal.errors.full_messages.join(', ')}"
    end
    
    redirect_to crm_contact_path(@contact)
  end

  def create_activity
    @activity = @contact.activities.build(
      user: current_user,
      activity_type: params[:activity_type],
      subject: params[:subject],
      description: params[:description],
      activity_date: params[:activity_date] || Time.current
    )
    
    if @activity.save
      flash[:success] = "Activity logged successfully!"
    else
      flash[:error] = "Failed to log activity: #{@activity.errors.full_messages.join(', ')}"
    end
    
    redirect_to crm_contact_path(@contact)
  end

  def create_note
    @note = @contact.notes.build(
      user: current_user,
      content: params[:note_content]
    )
    
    if @note.save
      # Log note creation activity
      @contact.activities.create!(
        user: current_user,
        activity_type: 'note_added',
        subject: "Note added",
        activity_date: Time.current,
        description: "New note added to contact"
      )
      
      flash[:success] = "Note added successfully!"
    else
      flash[:error] = "Failed to add note: #{@note.errors.full_messages.join(', ')}"
    end
    
    redirect_to crm_contact_path(@contact)
  end

  def create_task
    @task = @contact.tasks.build(
      user: current_user,
      title: params[:task_title],
      description: params[:task_description],
      due_date: params[:task_due_date],
      priority: params[:task_priority] || 'medium',
      status: 'pending'
    )
    
    if @task.save
      # Log task creation activity
      @contact.activities.create!(
        user: current_user,
        activity_type: 'task_created',
        subject: "Task created: #{@task.title}",
        activity_date: Time.current,
        description: "New task assigned with due date: #{@task.due_date}"
      )
      
      flash[:success] = "Task created successfully!"
    else
      flash[:error] = "Failed to create task: #{@task.errors.full_messages.join(', ')}"
    end
    
    redirect_to crm_contact_path(@contact)
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :email, :first_name, :last_name, :phone, :company, :job_title,
      :lifecycle_stage, :website, :address, :city, :state, :postal_code,
      :country, :source, :description, :lead_id
    )
  end

  def build_interaction_timeline
    timeline = []
    
    # Add activities
    @contact.activities.order(activity_date: :desc).limit(20).each do |activity|
      timeline << {
        type: 'activity',
        date: activity.activity_date,
        title: activity.subject,
        description: activity.description,
        user: activity.user&.email,
        icon: activity_icon(activity.activity_type)
      }
    end
    
    # Add notes
    @contact.notes.order(created_at: :desc).limit(10).each do |note|
      timeline << {
        type: 'note',
        date: note.created_at,
        title: 'Note Added',
        description: note.content.truncate(100),
        user: note.user&.email,
        icon: 'note'
      }
    end
    
    # Add deals
    @contact.deals.order(created_at: :desc).each do |deal|
      timeline << {
        type: 'deal',
        date: deal.created_at,
        title: "Deal: #{deal.deal_name}",
        description: "Amount: #{deal.amount} | Stage: #{deal.stage}",
        user: deal.user&.email,
        icon: 'deal'
      }
    end
    
    # Add tasks
    @contact.tasks.order(created_at: :desc).limit(10).each do |task|
      timeline << {
        type: 'task',
        date: task.created_at,
        title: "Task: #{task.title}",
        description: "Due: #{task.due_date} | Priority: #{task.priority}",
        user: task.user&.email,
        icon: task.completed? ? 'task_completed' : 'task_pending'
      }
    end
    
    timeline.sort_by { |item| item[:date] }.reverse
  end

  def activity_icon(activity_type)
    {
      'call' => 'phone',
      'email' => 'mail',
      'meeting' => 'calendar',
      'note' => 'note',
      'task' => 'task',
      'deal_created' => 'deal',
      'stage_change' => 'arrow-up',
      'contact_created' => 'user-plus',
      'contact_updated' => 'edit'
    }[activity_type] || 'activity'
  end
end