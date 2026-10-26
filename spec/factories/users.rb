FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "doctor#{n}@example.com" }
    password { "password123" }
    role { :doctor }
    name { "Dr. Test" }
    specialty { "General Medicine" }
    active { true }

    trait :admin do
      role { :admin }
      name { "Admin" }
      specialty { nil }
      sequence(:email) { |n| "admin#{n}@example.com" }
    end
  end
end
