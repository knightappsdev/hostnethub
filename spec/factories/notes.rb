FactoryBot.define do
  factory :note do
    content { "MyText" }
    contact { nil }
    lead { nil }
    deal { nil }
    user { nil }
  end
end
