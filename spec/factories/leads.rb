FactoryBot.define do
  factory :lead do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email) { |n| "lead#{n}@example.com" }
    phone { "+1-555-123-4567" }
    company { "Test Company" }
    website { "https://example.com" }
    source { "website" } # Must be in: website social_media email referral advertising direct other
    status { "new" } # Must be in: new in_progress contacted qualified unqualified  
    lifecycle_stage { "lead" } # Must be in: subscriber lead marketing_qualified_lead sales_qualified_lead opportunity customer evangelist other
    lead_score { 50 }
    association :user
  end
end
