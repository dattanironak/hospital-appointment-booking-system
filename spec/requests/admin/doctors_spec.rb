require "rails_helper"

RSpec.describe "Admin doctor management", type: :request do
  let(:admin) { create(:user, :admin, password: "password123") }

  def login_as(user)
    post "/session", params: { email: user.email, password: "password123" }
  end

  it "lets an admin create a doctor account" do
    login_as(admin)

    expect {
      post "/admin/doctors", params: { user: { name: "Dr. New", email: "new@example.com", specialty: "ENT", password: "doctorpass" } }
    }.to change(User, :count).by(1)

    doctor = User.doctor.find_by(email: "new@example.com")
    expect(doctor).to be_present
    expect(doctor.authenticate("doctorpass")).to be_truthy
  end

  it "lets an admin deactivate a doctor" do
    doctor = create(:user)
    login_as(admin)

    patch "/admin/doctors/#{doctor.id}", params: { user: { name: doctor.name, active: "0" } }

    expect(doctor.reload).not_to be_active
  end

  it "blocks a doctor from reaching the admin panel" do
    doctor = create(:user, password: "password123")
    login_as(doctor)

    get admin_root_path

    expect(response).to redirect_to(new_session_path)
  end
end
