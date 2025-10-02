FactoryBot.define do
  factory :task do
    title { "MyString" }
    description { "MyText" }
    due_date { "2025-10-02 11:43:05" }
    priority { "MyString" }
    status { "MyString" }
    contact { nil }
    lead { nil }
    deal { nil }
    user { nil }
    assigned_to { nil }
  end
end
