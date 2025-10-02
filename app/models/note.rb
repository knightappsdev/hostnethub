class Note < ApplicationRecord
  belongs_to :contact, optional: true
  belongs_to :lead, optional: true
  belongs_to :deal, optional: true
  belongs_to :user

  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :this_week, -> { where(created_at: Date.current.beginning_of_week..Date.current.end_of_week) }

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

  def excerpt(limit = 100)
    content.length > limit ? "#{content[0..limit]}..." : content
  end
end
