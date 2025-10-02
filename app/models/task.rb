class Task < ApplicationRecord
  belongs_to :contact, optional: true
  belongs_to :lead, optional: true
  belongs_to :deal, optional: true
  belongs_to :user
  belongs_to :assigned_to, class_name: 'User', optional: true

  validates :title, presence: true
  validates :priority, inclusion: { in: %w[low medium high urgent] }
  validates :status, inclusion: { in: %w[pending in_progress completed cancelled] }

  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_assigned_user, ->(user_id) { where(assigned_to_id: user_id) }
  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :overdue, -> { where('due_date < ? AND status != ?', Date.current, 'completed') }
  scope :due_today, -> { where(due_date: Date.current) }
  scope :due_this_week, -> { where(due_date: Date.current..Date.current.end_of_week) }
  scope :recent, -> { order(created_at: :desc) }

  def related_record
    contact || lead || deal
  end

  def related_record_name
    if contact
      contact.display_name
    elsif lead
      lead.full_name
    elsif deal
      deal.name
    else
      'Unknown'
    end
  end

  def overdue?
    due_date && due_date < Date.current && status != 'completed'
  end

  def completed?
    status == 'completed'
  end

  def priority_color
    case priority
    when 'urgent'
      'bg-red-100 text-red-800'
    when 'high'
      'bg-orange-100 text-orange-800'
    when 'medium'
      'bg-yellow-100 text-yellow-800'
    when 'low'
      'bg-green-100 text-green-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def status_color
    case status
    when 'completed'
      'bg-green-100 text-green-800'
    when 'in_progress'
      'bg-blue-100 text-blue-800'
    when 'pending'
      'bg-yellow-100 text-yellow-800'
    when 'cancelled'
      'bg-red-100 text-red-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
