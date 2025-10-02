class Contact < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lead, optional: true
  has_many :deals, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :lifecycle_stage, inclusion: { in: %w[subscriber lead marketing_qualified_lead sales_qualified_lead opportunity customer evangelist other] }
  validates :contact_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :by_lifecycle_stage, ->(stage) { where(lifecycle_stage: stage) }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_score, -> { where('contact_score >= ?', 70) }
  scope :customers, -> { where(lifecycle_stage: 'customer') }
  scope :with_deals, -> { joins(:deals).distinct }

  before_save :calculate_contact_score

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.present? ? full_name : email
  end

  def customer?
    lifecycle_stage == 'customer'
  end

  def total_deal_value
    deals.where(stage: 'closed_won').sum(:amount)
  end

  def active_deals_count
    deals.where.not(stage: ['closed_won', 'closed_lost']).count
  end

  def last_activity
    activities.order(activity_date: :desc).first
  end

  def days_since_last_contact
    return 0 unless last_activity
    (Date.current - last_activity.activity_date.to_date).to_i
  end

  private

  def calculate_contact_score
    score = 0
    
    # Base contact information
    score += 10 if email.present?
    score += 15 if phone.present?
    score += 20 if company.present?
    score += 10 if job_title.present?
    
    # Deal-based scoring
    score += 30 if deals.any?
    score += 20 if total_deal_value > 1000
    
    # Activity-based scoring
    recent_activities = activities.where('activity_date > ?', 30.days.ago).count
    score += [recent_activities * 5, 25].min
    
    # Lifecycle stage bonus
    case lifecycle_stage
    when 'customer'
      score += 40
    when 'opportunity'
      score += 30
    when 'sales_qualified_lead'
      score += 20
    when 'marketing_qualified_lead'
      score += 15
    end
    
    self.contact_score = [score, 100].min
  end
end
