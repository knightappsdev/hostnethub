class Lead < ApplicationRecord
  belongs_to :assigned_to, class_name: 'User', optional: true
  belongs_to :user, optional: true
  has_many :activities, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_one :contact, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :lifecycle_stage, inclusion: { in: %w[subscriber lead marketing_qualified_lead sales_qualified_lead opportunity customer evangelist other] }
  validates :status, inclusion: { in: %w[new in_progress contacted qualified unqualified] }
  validates :source, inclusion: { in: %w[website social_media email referral advertising direct other] }
  validates :lead_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :by_status, ->(status) { where(status: status) }
  scope :by_lifecycle_stage, ->(stage) { where(lifecycle_stage: stage) }
  scope :by_assigned_user, ->(user_id) { where(assigned_to_id: user_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_score, -> { where('lead_score >= ?', 70) }

  before_validation :calculate_lead_score, on: :create
  before_save :calculate_lead_score

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def qualified?
    %w[marketing_qualified_lead sales_qualified_lead].include?(lifecycle_stage)
  end

  def convert_to_contact!
    transaction do
      contact = Contact.create!(
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone: phone,
        company: company,
        lifecycle_stage: lifecycle_stage,
        contact_score: lead_score,
        user: user,
        lead: self
      )
      
      # Transfer activities, notes, and tasks to contact
      activities.update_all(contact_id: contact.id)
      notes.update_all(contact_id: contact.id)
      tasks.update_all(contact_id: contact.id)
      
      contact
    end
  end

  private

  def calculate_lead_score
    score = 0
    
    # Email provided
    score += 10 if email.present?
    
    # Phone provided
    score += 15 if phone.present?
    
    # Company provided
    score += 20 if company.present?
    
    # Website provided
    score += 10 if website.present?
    
    # Source scoring
    case source
    when 'referral'
      score += 25
    when 'website', 'social_media'
      score += 15
    when 'advertising'
      score += 10
    end
    
    # Recent activity bonus (only for existing records)
    score += 10 if persisted? && activities.where('created_at > ?', 7.days.ago).exists?
    
    self.lead_score = [score, 100].min
  end
end
