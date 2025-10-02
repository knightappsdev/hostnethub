module Crm::ApplicationHelper
  def lifecycle_stage_color(stage)
    case stage.to_s
    when 'subscriber'
      'bg-gray-100 text-gray-800'
    when 'lead'
      'bg-blue-100 text-blue-800'
    when 'marketing_qualified_lead'
      'bg-purple-100 text-purple-800'
    when 'sales_qualified_lead'
      'bg-indigo-100 text-indigo-800'
    when 'opportunity'
      'bg-yellow-100 text-yellow-800'
    when 'customer'
      'bg-green-100 text-green-800'
    when 'evangelist'
      'bg-pink-100 text-pink-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def lead_status_color(status)
    case status.to_s
    when 'new'
      'bg-blue-100 text-blue-800'
    when 'in_progress'
      'bg-yellow-100 text-yellow-800'
    when 'contacted'
      'bg-purple-100 text-purple-800'
    when 'qualified'
      'bg-green-100 text-green-800'
    when 'unqualified'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def lead_score_color(score)
    if score >= 80
      'text-green-600'
    elsif score >= 60
      'text-yellow-600'
    elsif score >= 40
      'text-orange-600'
    else
      'text-red-600'
    end
  end

  def lead_score_badge_color(score)
    if score >= 80
      'bg-green-100 text-green-800'
    elsif score >= 60
      'bg-yellow-100 text-yellow-800'
    elsif score >= 40
      'bg-orange-100 text-orange-800'
    else
      'bg-red-100 text-red-800'
    end
  end

  def format_currency(amount)
    return '$0' if amount.nil?
    "$#{number_with_delimiter(amount)}"
  end

  def format_lifecycle_stage(stage)
    stage.to_s.humanize.titleize
  end

  def format_lead_status(status)
    status.to_s.humanize.titleize
  end

  def format_lead_source(source)
    source.to_s.humanize.titleize
  end

  def deal_stage_color(stage)
    case stage.to_s
    when 'prospecting'
      'bg-blue-100 text-blue-800'
    when 'qualification'
      'bg-purple-100 text-purple-800'
    when 'proposal'
      'bg-yellow-100 text-yellow-800'
    when 'negotiation'
      'bg-orange-100 text-orange-800'
    when 'closed_won'
      'bg-green-100 text-green-800'
    when 'closed_lost'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def stage_color(stage)
    deal_stage_color(stage)
  end

  def status_color(status)
    lead_status_color(status)
  end
end