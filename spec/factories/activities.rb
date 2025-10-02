FactoryBot.define do
  factory :activity do
    activity_type { "MyString" }
    title { "MyString" }
    description { "MyText" }
    activity_date { "2025-10-02 11:42:38" }
    contact { nil }
    lead { nil }
    deal { nil }
    user { nil }
  end
end
