class Admin::CrmController < Admin::BaseController
  def dashboard
    @leads_count = Lead.count
    @contacts_count = Contact.count
    @deals_count = Deal.count
    @activities_count = Activity.count
    
    # Lead metrics
    @new_leads_this_month = Lead.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    @qualified_leads = Lead.where(lifecycle_stage: ['marketing_qualified_lead', 'sales_qualified_lead']).count
    @high_score_leads = Lead.high_score.count
    
    # Deal pipeline metrics
    @active_deals = Deal.active
    @deals_this_month = Deal.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
    @pipeline_value = @active_deals.sum(:amount)
    @weighted_pipeline = @active_deals.sum(&:weighted_amount)
    @deals_closed_won = Deal.won.where(actual_close_date: Date.current.beginning_of_month..Date.current.end_of_month)
    @monthly_revenue = @deals_closed_won.sum(:amount)
    
    # Deal stage breakdown
    @deals_by_stage = Deal.active.group(:stage).count
    @stage_values = Deal.active.group(:stage).sum(:amount)
    
    # Activity metrics
    @activities_this_week = Activity.this_week.count
    @activities_this_month = Activity.this_month.count
    @recent_activities = Activity.recent.limit(10).includes(:user, :contact, :lead, :deal)
    
    # Task metrics
    @open_tasks = Task.where.not(status: 'completed').count
    @overdue_tasks = Task.overdue.count
    @tasks_due_today = Task.due_today.count
    @recent_tasks = Task.recent.limit(5).includes(:user, :assigned_to, :contact, :lead, :deal)
    
    # Contact metrics
    @customers = Contact.customers.count
    @high_value_contacts = Contact.joins(:deals).where(deals: { stage: 'closed_won' }).distinct.count
    
    # Recent records for quick access
    @recent_leads = Lead.recent.limit(5).includes(:assigned_to)
    @recent_contacts = Contact.recent.limit(5)
    @recent_deals = Deal.recent.limit(5).includes(:contact, :assigned_to)
    
    # Performance metrics
    @conversion_rate = @leads_count > 0 ? ((@contacts_count.to_f / @leads_count) * 100).round(1) : 0
    @deal_close_rate = calculate_deal_close_rate
    @average_deal_size = @deals_closed_won.count > 0 ? (@monthly_revenue / @deals_closed_won.count).round(2) : 0
    
    # Charts data
    @monthly_leads_data = generate_monthly_leads_data
    @pipeline_stages_data = generate_pipeline_stages_data
    @activity_types_data = generate_activity_types_data
  end
  
  private
  
  def calculate_deal_close_rate
    total_closed = Deal.closed.where(created_at: Date.current.beginning_of_month..Date.current.end_of_month).count
    return 0 if total_closed == 0
    
    won_deals = Deal.won.where(actual_close_date: Date.current.beginning_of_month..Date.current.end_of_month).count
    ((won_deals.to_f / total_closed) * 100).round(1)
  end
  
  def generate_monthly_leads_data
    last_6_months = (5.months.ago.beginning_of_month..Date.current.end_of_month)
    
    last_6_months.group_by(&:month).map do |month, dates|
      month_start = dates.first.beginning_of_month
      month_end = dates.first.end_of_month
      leads_count = Lead.where(created_at: month_start..month_end).count
      
      {
        month: month_start.strftime('%B'),
        leads: leads_count
      }
    end
  end
  
  def generate_pipeline_stages_data
    stages = %w[prospecting qualification proposal negotiation]
    stages.map do |stage|
      deals = Deal.where(stage: stage)
      {
        stage: stage.humanize,
        count: deals.count,
        value: deals.sum(:amount).to_f
      }
    end
  end
  
  def generate_activity_types_data
    Activity.where(activity_date: Date.current.beginning_of_month..Date.current.end_of_month)
            .group(:activity_type)
            .count
            .map { |type, count| { type: type.humanize, count: count } }
  end
end