FactoryBot.define do
  factory :appointment do
    doctor factory: :user
    patient_name { "Jane Patient" }
    patient_phone { "+15550001111" }
    appointment_date { Date.current }
    start_time { "09:00" }
    end_time { "09:30" }
    status { :confirmed }
  end
end
