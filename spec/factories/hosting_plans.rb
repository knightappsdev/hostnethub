FactoryBot.define do
  factory :hosting_plan do
    name { "MyString" }
    description { "MyText" }
    price_monthly { "9.99" }
    websites_limit { 1 }
    storage_gb { 1 }
    bandwidth_gb { 1 }
    email_marketing { false }
    seo_tools { false }
    social_scheduler { false }
    migration_support { false }
    featured { false }
    active { false }
  end
end
