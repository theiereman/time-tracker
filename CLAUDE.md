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

# Linting (rubocop-rails-omakase rules)
bin/rubocop

# Security scan
bin/brakeman
bin/importmap audit   # JS dependency audit (also run in CI)

# Database
bin/rails db:migrate
bin/rails db:seed

# Background jobs (Solid Queue)
bin/jobs
```

CI (`.github/workflows/ci.yml`) runs, in order: `brakeman`, `bin/importmap audit`, `bin/rubocop`, then `bin/rails test` + `bin/rails test:system`.

## Code style

Do **not** add comments above methods. If a method can't be understood without a comment, make the code itself explicit (clear naming, extraction into a well-named private method) instead of adding a comment.

## Architecture

### Authentication
Magic-link only — no password login. `MagicLink` records are single-use (consumed on verification, expire in 15 min). The `Authentication` concern (included in `ApplicationController`) gates all actions; `Current.user` is the entry point for the authenticated user throughout a request.

Non-obvious auth details:
- **First login auto-creates the user** — `SessionsController` does `User.find_by(email) || create`; `User::MagicLinkable#send_magic_link` auto-detects sign-up vs sign-in.
- **Codes use Crockford base32** (`MagicLink::Code`) — 6 chars, ambiguous letters excluded; input is sanitized (uppercased, O→0/I→1/L→1) so users can mistype.
- **`pending_authentication_token`** — a signed cookie set during verification (`Authentication::ViaMagicLink`) ties the code to the originating browser, preventing cross-browser reuse.
- **Rate limited** — `SessionsController#create` (10/3 min) and code entry (10/15 min) via Rails `rate_limit` (Solid Cache backed).
- **Sessions** record `user_agent` and `ip_address`.

### Data model
- **User** — stores `settings` as JSON (via `store`); `wake_up_hour` and `sleep_hour` come from `User::Setupable`
- **Activity** — fixed-duration slots whose length comes from the user's `activity_duration_in_minutes` setting (15/30/60, via `User::Setupable`); `started_at` is snapped to the slot grid (`User#snap_to_activity_slot`) and `ended_at` derived from the duration. Activities store real `started_at`/`ended_at` intervals, so changing the setting never rewrites existing records. Day completion is measured in **filled slots on the current grid** (an activity fills a slot when it covers that slot's start), so it always matches what the day view shows; statistics still sum the real durations. Assigning a slot **absorbs** (destroys) any activity it overlaps (`ActivitiesController#absorb_overlapping_activities`), and uniqueness is a real interval-overlap check (`Activity.overlapping`), so a coarser slot cleanly replaces finer ones. The "sleep" category is protected and cannot be deleted or renamed. `ActivitiesController#mark_night_as_sleep` bulk-creates activities covering all of a user's sleep hours on a date and assigns them to the protected "Sommeil" category.
- **Activity::Category** — per-user, created with defaults on user creation. `protected: true` means immutable label/color and indestructible.

### Key non-obvious patterns
- **`User::Progress`** — query object scoped to a date range; used by both the day view (via `ProgressPresenter`) and the calendar view (via `MonthlyCalendar`). Call `User::Progress.for_the_day(user, date)` or `.for_the_month(...)`.
- **`ProgressPresenter`** — wraps a `User::Progress` and builds one `Slot` per slot of the day (`1440 / activity_duration_in_minutes`) via `Progress#slots_for`. Slots carry `:starts_at`, `:activity`, and `:night` (bool, based on `wake_up_hour`/`sleep_hour`); an activity fills every slot its interval covers, so a 1 h block spans four 15-minute slots.
- **`Day` / `MonthlyCalendar`** — plain Ruby objects for the calendar view; no ActiveRecord.
- **Presenters** live in `app/presenters/` and are plain Ruby objects — not view helpers. The statistics view uses `ActivitiesPerCategoryPresenter` (counts + top-categories table) and `HoursPerCategoryPresenter` (time-series for Chartkick).
- **Helpers** — `NavigationHelper` builds the nav items and resolves the active one via `Current.path`; `ApplicationHelper` has `contrasted_text_color` and `darken_color` for category-color UI.

### Localization (i18n)
The app is bilingual — **English (`:en`, default) and French (`:fr`)**, configured in `config/application.rb` (`available_locales`, `default_locale`, `fallbacks`). **Never hardcode UI text**; use Rails-native inference: lazy `t(".key")` in views/controllers, `activerecord.attributes`/`activerecord.errors.models` for labels and validation messages (models call `errors.add(:attr, :symbol)`, not literal strings), and `default_i18n_subject` in mailers.

- **Locale files are split per domain** under `config/locales/` (flat — auto-loaded by the default `config/locales/*.yml` glob, no `load_path` config). Each app file (`activities.yml`, `sessions.yml`, `settings.yml`, `models.yml`, `categories.yml`, `mailers.yml`, `shared.yml`, …) holds **both `en:` and `fr:`** so a feature's translations stay side-by-side. `fr.yml` holds only the Rails framework French defaults; English framework strings come from Rails' built-ins.

- **Locale resolution** — `ApplicationController#switch_locale` (an `around_action`) picks: persisted `Current.user.locale` → `Accept-Language` header → `default_locale`. Users override it via the language selector in Settings; it's stored in `User#settings` (`User::Setupable` store accessor).
- **Mailers** wrap delivery in `I18n.with_locale(user.locale)` since they run outside the request.
- **Default category labels** (`Activity::Category.create_default_categories_for`) are seeded via `I18n.t` at user-creation time; the protected "sleep" category is found by `protected: true` (not by label), so it's locale-independent.

### Navigation context
`Current.path`, `Current.action`, and `Current.controller` are set on every request (see `ApplicationController`) and are available in views/helpers for active-state logic in the nav.

### Flash / Turbo
Errors are shown via `helpers.turbo_flash_toast(:alert, message)` which renders a Turbo Stream — not a traditional redirect-with-flash.

### Stimulus controllers
Minimal — in `app/javascript/controllers/`: `autosubmit_controller.js`, `element_removal_controller.js`, and `press_controller.js` (button press scale/brightness animation).

### HAML + Tailwind classes with `/`
Tailwind classes containing `/` (e.g. `text-text/60`, `bg-primary/50`) **cannot** be used in HAML's dot notation (`.text-text/60` is invalid). Always put them in a `{class: "..."}` attribute:

```haml
-# ❌ invalid
%p.text-text/60

-# ✅ correct
%p{class: "text-text/60"}

-# ✅ correct (mix)
%p.mt-2.font-normal{class: "text-text/60"}
```
