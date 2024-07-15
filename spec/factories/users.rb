# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password" }

    trait :admin do
      role { "admin" }
    end

    trait :moderator do
      role { "moderator" }
    end

    trait :user do
      role { "user" }
    end
  end
end
