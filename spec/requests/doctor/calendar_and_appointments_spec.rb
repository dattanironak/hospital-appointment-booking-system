require "rails_helper"

RSpec.describe "Doctor calendar and appointment editing", type: :request do
  let(:doctor) { create(:user, password: "password123") }
  let(:other_doctor) { create(:user, password: "password123") }
  let(:monday) { Date.current.next_occurring(:monday) }

  before do
    create(:availability_rule, doctor: doctor, weekday: 1, start_time: "09:00", end_time: "10:30", slot_duration_minutes: 30)
    post "/session", params: { email: doctor.email, password: "password123" }
  end

  describe "GET /doctor/calendar" do
    it "shows booked counts for the month and the selected day's appointments" do
      create(:appointment, doctor: doctor, patient_name: "Alice Patient", appointment_date: monday, start_time: "09:00", end_time: "09:30")
      create(:appointment, doctor: doctor, patient_name: "Bob Patient", appointment_date: monday, start_time: "09:30", end_time: "10:00")
      create(:appointment, doctor: doctor, patient_name: "Gone Patient", appointment_date: monday, start_time: "10:00", end_time: "10:30", status: :cancelled)
      create(:appointment, doctor: other_doctor, patient_name: "Other Patient", appointment_date: monday)

      get doctor_calendar_path(date: monday.iso8601)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("2 bookings")
      expect(response.body).to include("Alice Patient", "Bob Patient")
      expect(response.body).not_to include("Gone Patient")
      expect(response.body).not_to include("Other Patient")
      expect(response.body).to include("10:00 AM") # the one open slot
    end

    it "navigates by month" do
      get doctor_calendar_path(month: "2027-02")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("February 2027")
    end

    it "falls back to the current month for an invalid date" do
      get doctor_calendar_path(date: "not-a-date")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(Date.current.strftime("%B %Y"))
    end
  end

  describe "PATCH /doctor/appointments/:id" do
    let!(:appointment) do
      create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:00", end_time: "09:30")
    end

    it "reschedules into an open slot" do
      patch doctor_appointment_path(appointment),
            params: { appointment: { appointment_date: monday.iso8601, start_time: "10:00", patient_name: "Jane Patient", patient_phone: "+15550001111" } }

      expect(response).to redirect_to(doctor_calendar_path(date: monday.iso8601))
      expect(appointment.reload.start_time.strftime("%H:%M")).to eq("10:00")
      expect(appointment.end_time.strftime("%H:%M")).to eq("10:30")
    end

    it "updates patient details while keeping the current slot" do
      patch doctor_appointment_path(appointment),
            params: { appointment: { appointment_date: monday.iso8601, start_time: "09:00", patient_name: "Janet", patient_phone: "+15559999999" } }

      expect(response).to redirect_to(doctor_calendar_path(date: monday.iso8601))
      expect(appointment.reload).to have_attributes(patient_name: "Janet", patient_phone: "+15559999999")
      expect(appointment.start_time.strftime("%H:%M")).to eq("09:00")
    end

    it "rejects a slot that's already booked" do
      create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:30", end_time: "10:00")

      patch doctor_appointment_path(appointment),
            params: { appointment: { appointment_date: monday.iso8601, start_time: "09:30", patient_name: "Jane Patient", patient_phone: "+15550001111" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(appointment.reload.start_time.strftime("%H:%M")).to eq("09:00")
    end

    it "rejects a time outside the doctor's hours" do
      patch doctor_appointment_path(appointment),
            params: { appointment: { appointment_date: monday.iso8601, start_time: "20:00", patient_name: "Jane Patient", patient_phone: "+15550001111" } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "404s for another doctor's appointment" do
      foreign = create(:appointment, doctor: other_doctor, appointment_date: monday)

      patch doctor_appointment_path(foreign),
            params: { appointment: { appointment_date: monday.iso8601, start_time: "10:00", patient_name: "X", patient_phone: "1" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /doctor/calendar open slot links" do
    it "links each open slot to the new appointment form" do
      get doctor_calendar_path(date: monday.iso8601)

      expect(response.body).to include(ERB::Util.html_escape(new_doctor_appointment_path(date: monday.iso8601, start_time: "09:00")))
    end
  end

  describe "GET /doctor/appointments/new" do
    it "preselects the clicked slot" do
      get new_doctor_appointment_path(date: monday.iso8601, start_time: "09:30")

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/value="09:30"[^>]*checked/)
    end
  end

  describe "POST /doctor/appointments" do
    def book(start_time, date: monday)
      post doctor_appointments_path,
           params: { appointment: { appointment_date: date.iso8601, start_time: start_time, patient_name: "New Patient", patient_phone: "+15552223333" } }
    end

    it "books an open slot for the current doctor and queues the WhatsApp confirmation" do
      expect { book("09:30") }
        .to change(doctor.appointments.confirmed, :count).by(1)
        .and have_enqueued_job(SendWhatsappConfirmationJob)

      expect(response).to redirect_to(doctor_calendar_path(date: monday.iso8601))
      appointment = doctor.appointments.last
      expect(appointment.start_time.strftime("%H:%M")).to eq("09:30")
      expect(appointment.end_time.strftime("%H:%M")).to eq("10:00")
    end

    it "rejects a slot that's already booked" do
      create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:00", end_time: "09:30")

      expect { book("09:00") }.not_to change(Appointment, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a time outside the doctor's hours" do
      expect { book("20:00") }.not_to change(Appointment, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "re-renders with errors when patient details are missing" do
      post doctor_appointments_path,
           params: { appointment: { appointment_date: monday.iso8601, start_time: "09:00", patient_name: "", patient_phone: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(Appointment.count).to eq(0)
    end
  end

  describe "GET /doctor/appointments/:id/edit" do
    it "lists open slots for the chosen date plus the current slot" do
      appointment = create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:00", end_time: "09:30")

      get edit_doctor_appointment_path(appointment)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("9:00 AM", "9:30 AM", "10:00 AM")
    end
  end
end
