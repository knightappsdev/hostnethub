FactoryBot.define do
  factory :contact do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email) { |n| "contact#{n}@example.com" }
    phone { "+1-555-123-4567" }
    company { "Acme Corp" }
    job_title { "Manager" }
    lifecycle_stage { "lead" }
    contact_score { 50 }
    association :user
  end
end
