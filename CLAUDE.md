# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pollito is a Ruby on Rails 8 application for betting pools on major events. Users create pools, make predictions, and compete on leaderboards. The app supports multiple event types including sports tournaments (FIFA World Cup 2026) and award ceremonies (Academy Awards/Oscars).

## Tech Stack

- **Ruby 3.3.5** with **Rails 8.1.2**
- **SQLite** for all environments (dev/test/prod)
- **Hotwire** (Turbo + Stimulus) for frontend interactivity
- **Tailwind CSS** with Flowbite components
- **Import Maps** for JavaScript (no Node.js build step for JS)
- **Solid Suite** (Cache, Queue, Cable) for background services
- **Kamal** for Docker deployment with Puma + Thruster

## Common Commands

```bash
# Development
bin/dev                          # Start all services (Rails + Tailwind watcher)
bin/rails server                 # Rails server only
bin/rails tailwindcss:watch      # Tailwind CSS compilation

# Testing
bin/rails test                   # Run all tests
bin/rails test test/models/match_test.rb  # Run single test file
bin/rails test:system            # System tests (Capybara + Selenium)
bin/rails db:test:prepare        # Prepare test database

# Code Quality
bin/rubocop                      # Ruby linting (Omakase style)
bin/rubocop -a                   # Auto-fix style issues
bin/brakeman                     # Security vulnerability scan
bin/importmap audit              # JS dependency security

# Database
bin/rails db:migrate             # Run migrations
bin/rails console                # Interactive Rails console
```

## Architecture

### Domain Model Hierarchy

```
Event (tournament/ceremony)
  └── Stage (Group Stage, Round of 16, Award Categories, etc.)
       └── Match
            ├── match_type: one_on_one | multi_nominee
            ├── MatchParticipant (join table)
            │    ├── Participant (team/nominee)
            │    └── Result (actual score/winner)
            └── Prediction (user forecast)
                 └── PredictedResult (predicted score per participant)

BettingPool (belongs_to Event)
  ├── is_public: true/false
  └── BettingPoolMembership (user in pool, tracks score/rank)
```

### Match Types

- **one_on_one** (Sports): Two participants with score predictions (e.g., Brazil 2 - Argentina 1)
- **multi_nominee** (Awards): Multiple participants, pick one winner (e.g., Oscar categories)

### Scoring System (`app/models/concerns/prediction/scorable.rb`)

Points are calculated when `Match#mark_as_final!` is called:

**One-on-One (Sports):**
- **Exact score match**: 2 points per correct participant score
- **Correct outcome** (win/draw): 3 points

**Multi-Nominee (Awards):**
- **Correct winner**: 5 points

Flow: `match.mark_as_final!` → `prediction.calculate_score!` → updates `PredictedResult.points`, `Prediction.outcome_points`, `Prediction.total_points`, and `BettingPoolMembership.score`

### Match Status Lifecycle

Enum values in `Match#match_status`:
- `unset` (0): Participants unknown (pending playoff fixture)
- `bets_open` (1): Predictions allowed
- `bets_closed` (2): No more predictions (stage deadline: 12h before first match)
- `in_progress` (3): Match started
- `finished` (4): Match complete, scoring locked

Status is automatically assigned via `assign_lifecycle_status` callback based on participant count and stage betting cutoff.

### Authentication

**Passwordless OTP Authentication:**
- `EmailVerification` model generates 6-digit OTP codes (BCrypt hashed)
- 15-minute expiry, 5-attempt limit
- `OtpSessionsController` handles login flow
- `OtpMailer` sends verification codes
- Admin users can additionally authenticate with password

**Session Management:**
- `Authentication` concern in `app/controllers/concerns/`
- `Current` for thread-safe request context
- Methods: `require_authentication`, `start_new_session_for(user)`, `require_admin!`

### Admin Namespace

Admin controllers in `app/controllers/admin/` handle:
- Tournament management with FIFA JSON import
- User management
- Match results finalization

## Key Services

### FifaTournamentImporter (`app/services/fifa_tournament_importer.rb`)
- Parses FIFA API JSON data
- Creates Event, Stages, Participants, Matches, MatchParticipants
- Transactional import with find_or_initialize pattern
- Statistics tracking (created/updated counts)

### OscarNominationsImporter (`app/services/oscar_nominations_importer.rb`)
- Parses HTML with Nokogiri
- Creates Event "98th Academy Awards"
- Each category becomes a Match with `match_type: multi_nominee`
- Nominees as Participants
- Category-specific name extraction (films, people, songs)

## Key Files

- `app/models/match.rb` - Match logic, status lifecycle
- `app/models/prediction.rb` - User predictions with scoring
- `app/models/concerns/prediction/scorable.rb` - Score calculation logic
- `app/models/betting_pool.rb` - Pool management, public/private visibility
- `app/services/fifa_tournament_importer.rb` - FIFA tournament import
- `app/services/oscar_nominations_importer.rb` - Oscar nominations import
- `app/controllers/predictions_controller.rb` - Prediction CRUD with Turbo
- `app/controllers/betting_pools_controller.rb` - Pool management
- `app/controllers/concerns/authentication.rb` - Auth helpers
- `app/controllers/otp_sessions_controller.rb` - Passwordless login
- `config/routes.rb` - RESTful routes with admin namespace
- `db/schema.rb` - Current database schema

## Testing Patterns

- Fixtures in `test/fixtures/*.yml`
- Unit tests: `test/models/`, `test/controllers/`
- System tests: `test/system/` (Capybara + Selenium with Chrome)
- CI runs: `bin/rails db:test:prepare test test:system`

## Code Style

- **RuboCop Rails Omakase** style guide
- 2-space indentation
- Standard Rails naming: PascalCase classes, snake_case methods
- Run `bin/rubocop` before committing
