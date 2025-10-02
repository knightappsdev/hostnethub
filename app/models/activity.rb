class Activity < ApplicationRecord
  belongs_to :contact, optional: true
  belongs_to :lead, optional: true
  belongs_to :deal, optional: true
  belongs_to :user

  validates :activity_type, presence: true, inclusion: { in: %w[call email meeting task note] }
  validates :title, presence: true
  validates :activity_date, presence: true

  scope :by_type, ->(type) { where(activity_type: type) }
  scope :recent, -> { order(activity_date: :desc) }
  scope :this_week, -> { where(activity_date: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :this_month, -> { where(activity_date: Date.current.beginning_of_month..Date.current.end_of_month) }

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

  def icon_class
    case activity_type
    when 'call'
      'fa-phone'
    when 'email'
      'fa-envelope'
    when 'meeting'
      'fa-calendar'
    when 'task'
      'fa-tasks'
    when 'note'
      'fa-sticky-note'
    else
      'fa-circle'
    end
  end
end
