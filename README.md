# Onboarding Wizard

A multi-step onboarding wizard for a fictional subscription service, built for
the Rails engineer challenge. A visitor signs up, works through three form
steps - personal details, address, preferences - and confirms everything on a
summary screen. Progress is stored in the database at every step, so an
incomplete onboarding can be resumed and queried later.

## Running locally

Requirements: Ruby 3.2.2 (see `.ruby-version`) and PostgreSQL running locally.

```sh
bin/setup        # bundle install, prepares the databases, boots the app
```

or, step by step:

```sh
bundle install
bin/rails db:prepare
bin/dev          # runs the server plus the Tailwind watcher (Procfile.dev)
```

Then visit http://localhost:3000.

Tests and checks:

```sh
bin/rails test   # models + request tests
bin/rubocop      # style (rubocop-rails-omakase)
bin/brakeman     # static security analysis
```

## Design decisions

### Data model: one table per step, completion as stored state

`Onboarding` is a thin root holding only identity and flow state:
a `token`, the `current_step` resume pointer, and a
`completed_at` stamp. Every answer a visitor gives lives on a child record -
one `has_one` table per form step:

| Step | Model                          | Table              |
|---|--------------------------------|--------------------|
| 1. Personal details | `Onboardings::PersonalDetails` | `personal_details` |
| 2. Address | `Onboardings::Address`         | `addresses`        |
| 3. Preferences | `Onboardings::Preferences`     | `preferences`      |
| 4. Summary | - (no record; a review screen) | -                  |

Each child is unique on `onboarding_id`, so the database enforces one record per step. Each child also owns
its **own `completed_at`**: "has this step been finished?" is
set once on a successful save (`OnboardingStep#completed!`, idempotent), not
something re-derived by re-running validations. That makes the questions this
data exists to answer cheap and index-friendly:

```ruby
Onboarding.where(completed_at: nil)             # incomplete onboardings
Onboardings::Address.where(completed_at: nil)   # who stalled at the address step
```

Shared step behaviour (`belongs_to :onboarding, touch: true`, `completed?`,
`completed!`) lives in the `OnboardingStep` model concern. `touch: true`
keeps the parent's `updated_at` moving with every child save, so
"last activity" ordering and abandoned-onboarding queries stay honest.

### File structure: everything step-shaped is namespaced under `Onboardings::`

The namespace mirrors the routes: singular resources nested under
`resource :onboarding`, e.g. `/onboarding/personal_details`. URLs carry no
IDs — the visitor's onboarding is identified by a signed session token, so
records can't be enumerated or hijacked by guessing.

### The "Steps"

Every form step is a singular resource with only `show` and `update`.
There is deliberately no `new`/`create` pair: the step record may or may not
exist when the visitor arrives (first visit vs. coming back), so the
controller finds-or-builds it in a `before_action` and `update`.

The three step controllers share `Onboardings::StepController`, which owns
the whole update flow (save → mark completed → advance `current_step` →
303 redirect, or 422 re-render). Each subclass supplies three small hooks:
`step_record`, `step_params`, and `next_step`.

The summary is the exception that proves the design: it has no record and no
form. It renders all three children, guards against early arrivals with a redirection 
and its Confirm button POSTs to a completions endpoint that calls `Onboarding#complete!`.

### If I had more time

- **A central `Stepable` concern to own step progression**. The flow order
  currently lives in `Onboarding::STEPS` while each step controller hardcodes
  its own `next_step`, so "what comes after what" is split across four files.
  A `Stepable` concern on `Onboarding` would own the ordered step list and
  expose methods as needed and a step-order guard, letting the controllers 
  ask the model where to go instead of knowing it themselves. 
- **Hotwire/Turbo for smoother transitions.** The app is deliberately plain
  server-rendered full-page navigation. Turbo Frames around the step card
  would make moving between steps feel instant without changing any
  controller code, and a Turbo Stream on validation failure could re-render
  just the offending field rather than the whole form.
- **More time on the views.** A visual progress indicator (the "Step n of 4"
  badge as a proper stepper with completed ticks), field-level hints,
  autofocus on the first field of each step, and a proper completed/thank-you
  screen rather than a banner on the summary.
- **Edit-in-place on the summary.** Each summary section could swap to an
  inline Turbo Frame form on "Edit", saving users a round-trip through the
  wizard to fix a typo.
- **Guard against URL-jumping ahead.** The summary refuses early arrivals,
  but nothing stops a visitor PATCHing `/onboarding/preferences` before
  finishing earlier steps.
- **Smaller polish:** save half-typed input when navigating Back (submit via
  `validate: false` instead of a plain link).
- **User model:** Implement a more robust user model with better validation and error handling for when
onboarding is complete.
