FactoryBot.define do
  factory :deal do
    name { "MyString" }
    description { "MyText" }
    amount { "9.99" }
    stage { "MyString" }
    probability { 1 }
    expected_close_date { "2025-10-02" }
    actual_close_date { "2025-10-02" }
    contact { nil }
    user { nil }
    assigned_to { nil }
  end
end
