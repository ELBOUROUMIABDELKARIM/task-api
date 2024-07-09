# spec/factories/tasks.rb
FactoryBot.define do
  factory :task do
    association :user
    title { "Test Task" }
    description { "This is a test task." }
  end
end
