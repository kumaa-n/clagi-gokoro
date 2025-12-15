FactoryBot.define do
  factory :song do
    sequence(:title) { |n| "テスト曲#{n}" }
    composer { "作曲者" }
    arranger { "編曲者" }
  end
end
