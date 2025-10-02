class Deal < ApplicationRecord
  belongs_to :contact
  belongs_to :user, optional: true
  belongs_to :assigned_to, class_name: 'User', optional: true
  has_many :activities, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :stage, inclusion: { in: %w[prospecting qualification proposal negotiation closed_won closed_lost] }
  validates :probability, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :by_assigned_user, ->(user_id) { where(assigned_to_id: user_id) }
  scope :active, -> { where.not(stage: ['closed_won', 'closed_lost']) }
  scope :won, -> { where(stage: 'closed_won') }
  scope :lost, -> { where(stage: 'closed_lost') }
  scope :closed, -> { where(stage: ['closed_won', 'closed_lost']) }
  scope :expected_this_month, -> { where(expected_close_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :overdue, -> { where('expected_close_date < ? AND stage NOT IN (?)', Date.current, ['closed_won', 'closed_lost']) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :update_probability_by_stage, on: :create
  before_save :update_probability_by_stage
  after_update :update_contact_lifecycle_stage

  def closed?
    %w[closed_won closed_lost].include?(stage)
  end

  def won?
    stage == 'closed_won'
  end

  def lost?
    stage == 'closed_lost'
  end

  def overdue?
    expected_close_date && expected_close_date < Date.current && !closed?
  end

  def days_until_close
    return 0 unless expected_close_date
    (expected_close_date - Date.current).to_i
  end

  def weighted_amount
    (amount * probability / 100.0).round(2)
  end

  def stage_color
    case stage
    when 'prospecting'
      'bg-gray-100 text-gray-800'
    when 'qualification'
      'bg-blue-100 text-blue-800'
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

  def stage_position
    stages = %w[prospecting qualification proposal negotiation closed_won closed_lost]
    stages.index(stage) || 0
  end

  private

  def update_probability_by_stage
    case stage
    when 'prospecting'
      self.probability = 10
    when 'qualification'
      self.probability = 25
    when 'proposal'
      self.probability = 50
    when 'negotiation'
      self.probability = 75
    when 'closed_won'
      self.probability = 100
      self.actual_close_date = Date.current unless actual_close_date
    when 'closed_lost'
      self.probability = 0
      self.actual_close_date = Date.current unless actual_close_date
    end
  end

  def update_contact_lifecycle_stage
    return unless contact
    
    if stage == 'closed_won' && contact.lifecycle_stage != 'customer'
      contact.update(lifecycle_stage: 'customer')
    elsif stage == 'negotiation' && contact.lifecycle_stage == 'sales_qualified_lead'
      contact.update(lifecycle_stage: 'opportunity')
    end
  end
end
