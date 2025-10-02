class HostingPlan < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :price_monthly, presence: true, numericality: { greater_than: 0 }
  validates :websites_limit, presence: true
  validates :storage_gb, presence: true
  validates :bandwidth_gb, presence: true
  
  # Custom validations for -1 (unlimited) values
  validate :websites_limit_valid
  validate :storage_gb_valid
  validate :bandwidth_gb_valid
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :by_price, -> { order(:price_monthly) }
  
  # Methods
  def monthly_savings
    savings = 0
    savings += 29 if email_marketing?
    savings += 19 if seo_tools?
    savings += 19 if social_scheduler?
    savings
  end
  
  def annual_savings
    monthly_savings * 12
  end
  
  def free_tools_count
    count = 0
    count += 1 if email_marketing?
    count += 1 if seo_tools?
    count += 1 if social_scheduler?
    count += 1 if migration_support?
    count
  end
  
  def storage_display
    storage_gb == -1 ? "Unlimited" : "#{storage_gb}GB"
  end
  
  def bandwidth_display
    bandwidth_gb == -1 ? "Unlimited" : "#{bandwidth_gb}GB"
  end
  
  def websites_display
    websites_limit == -1 ? "Unlimited" : websites_limit.to_s
  end
  
  private
  
  def websites_limit_valid
    return if websites_limit.nil?
    return if websites_limit == -1 # Allow unlimited
    return if websites_limit > 0
    errors.add(:websites_limit, "must be greater than 0 or -1 for unlimited")
  end
  
  def storage_gb_valid
    return if storage_gb.nil?
    return if storage_gb == -1 # Allow unlimited
    return if storage_gb > 0
    errors.add(:storage_gb, "must be greater than 0 or -1 for unlimited")
  end
  
  def bandwidth_gb_valid
    return if bandwidth_gb.nil?
    return if bandwidth_gb == -1 # Allow unlimited
    return if bandwidth_gb > 0
    errors.add(:bandwidth_gb, "must be greater than 0 or -1 for unlimited")
  end
end
