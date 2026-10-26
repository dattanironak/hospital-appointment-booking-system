# Hospital Appointment Booking

Rails app for clinic staff, with two roles:

- **Admin** — creates and manages doctor accounts, views all appointments.
- **Doctor** — sets weekly availability, blocks slots, and books, reschedules or cancels appointments from a calendar.

Both sign in at `/` with email and password.

## Requirements

- Ruby 3.3.11
- PostgreSQL

## Setup

```sh
bin/setup          # installs gems, prepares the database, starts the server
bin/rails db:seed  # creates the admin account
```

The seed admin defaults to `admin@example.com` / `changeme123`. Set `ADMIN_EMAIL` and `ADMIN_PASSWORD` before seeding to change it.

## Tests

```sh
bundle exec rspec
```

## Configuration

In development, copy `.env.example` to `.env` and fill it in; it is loaded automatically and git-ignored. In production, set these as environment variables on Render.

| Variable | Purpose |
| --- | --- |
| `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_WHATSAPP_FROM` | WhatsApp confirmation sent when a doctor books an appointment. Skipped if unset. |
| `DATABASE_URL` | Production database. |
| `RAILS_MASTER_KEY` | Production credentials. |

## Deployment

`render.yaml` defines the Render web service (Docker) and its PostgreSQL database.
