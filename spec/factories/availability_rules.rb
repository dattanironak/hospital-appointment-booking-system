FactoryBot.define do
  factory :availability_rule do
    doctor factory: :user
    weekday { 1 }
    start_time { "09:00" }
    end_time { "17:00" }
    slot_duration_minutes { 30 }
  end
end
