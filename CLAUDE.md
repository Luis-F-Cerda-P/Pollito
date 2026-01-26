# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pollito is a Ruby on Rails 8 application for World Cup betting pools. Users create pools, predict match scores, and compete on leaderboards. The app targets the 2026 FIFA World Cup and supports bilingual content (English/Spanish).

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
Event (tournament)
  └── Stage (Group Stage, Round of 16, etc.)
       └── Match
            ├── MatchParticipant (join table)
            │    ├── Participant (team)
            │    └── Result (actual score)
            └── Prediction (user forecast)
                 └── PredictedResult (predicted score per participant)

BettingPool (belongs_to Event)
  └── BettingPoolMembership (user in pool, tracks score/rank)
```

### Scoring System (`app/models/concerns/prediction/scorable.rb`)

Points are calculated when `Match#mark_as_final!` is called:
- **Exact score match**: 2 points per participant
- **Correct outcome** (win/draw): 3 points

Flow: `match.mark_as_final!` → `prediction.calculate_score!` → updates `PredictedResult.points`, `Prediction.outcome_points`, `Prediction.total_points`, and `BettingPoolMembership.score`

### Match Status Lifecycle

Enum values in `Match#match_status`:
- `unset` (0): Participants unknown
- `bets_open` (1): Predictions allowed
- `bets_closed` (2): No more predictions
- `in_progress` (3): Match started
- `finished` (4): Match complete, scoring locked

### Authentication

Session-based authentication using Rails 8 patterns:
- `Authentication` concern in `app/controllers/concerns/`
- `Current` for thread-safe request context
- Methods: `require_authentication`, `start_new_session_for(user)`

### Admin Namespace

Admin controllers in `app/controllers/admin/` handle tournament management, including the `FifaTournamentImporter` service for importing match data from FIFA API JSON.

## Key Files

- `app/models/concerns/prediction/scorable.rb` - Score calculation logic
- `app/services/fifa_tournament_importer.rb` - Tournament data import
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
