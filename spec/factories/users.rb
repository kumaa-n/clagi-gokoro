FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "testuser#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
