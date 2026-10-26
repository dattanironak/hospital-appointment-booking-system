require "rails_helper"

RSpec.describe "Doctor tenant isolation", type: :request do
  let(:doctor_a) { create(:user, name: "Dr. A", email: "a@example.com", password: "password123") }
  let(:doctor_b) { create(:user, name: "Dr. B", email: "b@example.com", password: "password123") }

  def login_as(user)
    post "/session", params: { email: user.email, password: "password123" }
  end

  it "never shows doctor A's upcoming appointments on doctor B's dashboard" do
    create(:appointment, doctor: doctor_a, patient_name: "Alice Patient", appointment_date: Date.tomorrow)
    create(:appointment, doctor: doctor_b, patient_name: "Bob Patient", appointment_date: Date.tomorrow)

    login_as(doctor_b)
    get doctor_root_path

    expect(response.body).to include("Bob Patient")
    expect(response.body).not_to include("Alice Patient")
  end

  it "404s when doctor B tries to cancel doctor A's appointment by id" do
    appointment = create(:appointment, doctor: doctor_a, appointment_date: Date.tomorrow)

    login_as(doctor_b)
    delete "/doctor/appointments/#{appointment.id}"

    expect(response).to have_http_status(:not_found)
    expect(appointment.reload).to be_confirmed
  end

  it "404s when doctor B tries to delete doctor A's availability rule by id" do
    rule = create(:availability_rule, doctor: doctor_a)

    login_as(doctor_b)
    delete "/doctor/availability_rules/#{rule.id}"

    expect(response).to have_http_status(:not_found)
    expect(rule.reload).to be_persisted
  end

  it "404s when doctor B tries to delete doctor A's blocked slot by id" do
    slot = create(:blocked_slot, doctor: doctor_a)

    login_as(doctor_b)
    delete "/doctor/blocked_slots/#{slot.id}"

    expect(response).to have_http_status(:not_found)
    expect(slot.reload).to be_persisted
  end

  it "redirects an admin away from the doctor dashboard" do
    admin = create(:user, :admin, password: "password123")

    login_as(admin)
    get doctor_root_path

    expect(response).to redirect_to(new_session_path)
  end
end
