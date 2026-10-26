FactoryBot.define do
  factory :blocked_slot do
    doctor factory: :user
    date { Date.current }
    start_time { nil }
    end_time { nil }
  end
end
