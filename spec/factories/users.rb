# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "password" }
    trait :empty_name do
      name {""}
    end
    trait :empty_email do
      email {""}
    end
  end

end
