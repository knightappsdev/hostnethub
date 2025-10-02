class Crm::DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    # CRM Dashboard Metrics
    @total_leads = Lead.where(user: current_user).count
    @total_contacts = Contact.where(user: current_user).count
    @total_deals = Deal.where(user: current_user).count
    @total_revenue = Deal.where(user: current_user, stage: 'closed_won').sum(:amount)
    
    # Lead Pipeline Visualization Data
    @pipeline_stages = {
      'New' => Lead.where(user: current_user, status: 'new').count,
      'In Progress' => Lead.where(user: current_user, status: 'in_progress').count,
      'Contacted' => Lead.where(user: current_user, status: 'contacted').count,
      'Qualified' => Lead.where(user: current_user, status: 'qualified').count,
      'Unqualified' => Lead.where(user: current_user, status: 'unqualified').count
    }
    
    # Deal Pipeline
    @deal_pipeline = {
      'Prospecting' => Deal.where(user: current_user, stage: 'prospecting').sum(:amount),
      'Qualification' => Deal.where(user: current_user, stage: 'qualification').sum(:amount),
      'Proposal' => Deal.where(user: current_user, stage: 'proposal').sum(:amount),
      'Negotiation' => Deal.where(user: current_user, stage: 'negotiation').sum(:amount),
      'Closed Won' => Deal.where(user: current_user, stage: 'closed_won').sum(:amount),
      'Closed Lost' => Deal.where(user: current_user, stage: 'closed_lost').sum(:amount)
    }
    
    # Recent Activities (both lead and contact activities)
    @recent_activities = Activity.joins('LEFT JOIN leads ON activities.lead_id = leads.id LEFT JOIN contacts ON activities.contact_id = contacts.id')
                                .where('leads.user_id = ? OR contacts.user_id = ?', current_user.id, current_user.id)
                                .order(activity_date: :desc)
                                .limit(10)
                                .includes(:lead, :contact, :user)
    
    # Top Performing Leads
    @top_leads = Lead.where(user: current_user)
                    .where('lead_score > ?', 50)
                    .order(lead_score: :desc)
                    .limit(5)
    
    # Monthly Performance
    @monthly_leads = Lead.where(user: current_user)
                        .where('created_at >= ?', 6.months.ago)
                        .group_by_month(:created_at)
                        .count
                        
    @monthly_revenue = Deal.where(user: current_user)
                          .where('created_at >= ?', 6.months.ago)
                          .where(stage: 'closed_won')
                          .group_by_month(:created_at)
                          .sum(:amount)
    
    # Conversion Rates
    @conversion_rates = calculate_conversion_rates
    
    # Tasks Due Today
    @tasks_due_today = Task.where(user: current_user)
                          .where(due_date: Date.current)
                          .where.not(status: 'completed')
                          .order(:due_date)
                          .limit(5)
  end
  
  private
  
  def calculate_conversion_rates
    total_leads = Lead.where(user: current_user).count
    return {} if total_leads.zero?
    
    {
      'Lead to Qualified' => (Lead.where(user: current_user, status: 'qualified').count.to_f / total_leads * 100).round(1),
      'Lead to Contact' => (Contact.joins(:lead).where(leads: { user: current_user }).count.to_f / total_leads * 100).round(1),
      'Contact to Customer' => (Contact.where(user: current_user, lifecycle_stage: 'customer').count.to_f / Contact.where(user: current_user).count * 100).round(1)
    }
  end
end
