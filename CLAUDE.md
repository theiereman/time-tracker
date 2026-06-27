# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

Rails 8 app using:
- **SQLite** via Solid Cache / Solid Queue / Solid Cable (no Redis/Postgres)
- **Tailwind CSS v4** (via `tailwindcss-rails`) — watch with `bin/rails tailwindcss:watch`
- **HAML** templates (not ERB)
- **Hotwire** (Turbo + Stimulus) — no React/Vue
- **Importmap** for JS (no bundler/webpack)
- **Propshaft** for assets
- **Chartkick** for charts
- **Kamal** for deployment

## Commands

```bash
# Development (runs server + Tailwind watcher)
bin/dev

# Run tests
bin/rails test
bin/rails test test/models/activity_test.rb   # single file
bin/rails test:system                          # system tests (Capybara + Selenium)

# Linting
bin/rubocop

# Security scan
bin/brakeman

# Database
bin/rails db:migrate
bin/rails db:seed
```

## Architecture

### Authentication
Magic-link only — no password login. `MagicLink` records are single-use (consumed on verification, expire in 15 min). The `Authentication` concern (included in `ApplicationController`) gates all actions; `Current.user` is the entry point for the authenticated user throughout a request.

### Data model
- **User** — stores `settings` as JSON (via `store`); `wake_up_hour` and `sleep_hour` come from `User::Setupable`
- **Activity** — one hour fixed-duration slots, snapped to the start of the hour. A user can have at most 24 activities per day (one per hour). The "sleep" category is protected and cannot be deleted or renamed.
- **Activity::Category** — per-user, created with defaults on user creation. `protected: true` means immutable label/color and indestructible.

### Key non-obvious patterns
- **`User::Progress`** — query object scoped to a date range; used by both the day view (via `ProgressPresenter`) and the calendar view (via `MonthlyCalendar`). Call `User::Progress.for_the_day(user, date)` or `.for_the_month(...)`.
- **`ProgressPresenter`** — wraps a `User::Progress` and builds 24 `Slot` structs (one per hour) for the activity feed. Slots carry `:hour`, `:activity`, and `:night` (bool, based on `wake_up_hour`/`sleep_hour`).
- **`Day` / `MonthlyCalendar`** — plain Ruby objects for the calendar view; no ActiveRecord.
- **Presenters** live in `app/presenters/` and are plain Ruby objects — not view helpers.

### Localization
The app UI is in French. Validation error messages and category names are in French. The locale files are in `config/locales/fr.yml`; date/time formats follow French conventions.

### Navigation context
`Current.path`, `Current.action`, and `Current.controller` are set on every request (see `ApplicationController`) and are available in views/helpers for active-state logic in the nav.

### Flash / Turbo
Errors are shown via `helpers.turbo_flash_toast(:alert, message)` which renders a Turbo Stream — not a traditional redirect-with-flash.

### Stimulus controllers
Minimal: `autosubmit_controller.js` and `element_removal_controller.js` in `app/javascript/controllers/`.

### HAML + Tailwind classes avec `/`
Les classes Tailwind contenant `/` (ex. `text-text/60`, `bg-primary/50`) ne peuvent **pas** être utilisées dans la notation pointée HAML (`.text-text/60` est invalide). Il faut toujours les mettre dans un attribut `{class: "..."}` :

```haml
-# ❌ invalide
%p.text-text/60

-# ✅ correct
%p{class: "text-text/60"}

-# ✅ correct (mix)
%p.mt-2.font-normal{class: "text-text/60"}
```
