require "rails_helper"

RSpec.describe SlotCalculator do
  let(:doctor) { create(:user) }
  let(:monday) { Date.current.next_occurring(:monday) }

  before do
    create(:availability_rule, doctor: doctor, weekday: 1, start_time: "09:00", end_time: "10:30", slot_duration_minutes: 30)
  end

  it "generates slots across the full window at the configured duration" do
    slots = described_class.call(doctor: doctor, date: monday)

    expect(slots.map { |s| s.start_time.strftime("%H:%M") }).to eq(%w[09:00 09:30 10:00])
  end

  it "excludes a date in the past" do
    slots = described_class.call(doctor: doctor, date: Date.current - 1)
    expect(slots).to be_empty
  end

  it "returns nothing for a weekday with no availability rule" do
    other_day = monday + 1 # Tuesday, no rule defined
    expect(described_class.call(doctor: doctor, date: other_day)).to be_empty
  end

  it "excludes a slot already covered by a confirmed appointment" do
    create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:30", end_time: "10:00")

    slots = described_class.call(doctor: doctor, date: monday)
    expect(slots.map { |s| s.start_time.strftime("%H:%M") }).to eq(%w[09:00 10:00])
  end

  it "does not exclude a slot covered only by a cancelled appointment" do
    create(:appointment, doctor: doctor, appointment_date: monday, start_time: "09:30", end_time: "10:00", status: :cancelled)

    slots = described_class.call(doctor: doctor, date: monday)
    expect(slots.map { |s| s.start_time.strftime("%H:%M") }).to include("09:30")
  end

  it "excludes slots overlapping a partial block" do
    create(:blocked_slot, doctor: doctor, date: monday, start_time: "09:15", end_time: "10:00")

    slots = described_class.call(doctor: doctor, date: monday)
    expect(slots.map { |s| s.start_time.strftime("%H:%M") }).to eq(%w[10:00])
  end

  it "returns nothing when the whole day is blocked" do
    create(:blocked_slot, doctor: doctor, date: monday, start_time: nil, end_time: nil)

    expect(described_class.call(doctor: doctor, date: monday)).to be_empty
  end
end
