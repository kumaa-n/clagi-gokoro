FactoryBot.define do
  factory :review_favorite do
    association :user
    association :review
  end
end
