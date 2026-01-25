# Pollito Development Roadmap

## Current Status
- ✅ Core models (Event, Stage, Match, BettingPool, Prediction, Membership)
- ✅ Basic CRUD for pools and memberships
- ✅ User authentication
- ✅ Simple homepage
- 🚧 Score calculation logic
- 🚧 Leaderboard display
- 🚧 Prediction submission flow
- 📋 Event importers (need updating)
- 📋 Dev initialization script

---

## Immediate Priorities (Next 2-3 Sessions)

### 1. Score Calculation System ⭐ CRITICAL
**Goal:** Automatically calculate points when match results are finalized

- Add `score` column to `predictions` table for audit trail
- Create `ScoreCalculator` service object
  - Exact score match = X points
  - Correct winner/draw = Y points
  - Goal difference bonus = Z points (optional)
- Update `betting_pool_memberships.score` when matches complete
- Add background job for batch recalculation (if needed)
- **Considerations:**
  - When to trigger: on match result update, or batch nightly?
  - Handle edge cases: ties, postponed matches, incomplete results
  - Idempotency: can we recalculate safely?

### 2. Scoreboard/Leaderboard UX
**Goal:** Show rankings within betting pools

- Leaderboard page per betting pool
- Show: rank, user, total score, prediction accuracy %
- Breakdown by stage (Group Stage points, Knockout points, etc.)
- Recent score changes / activity feed
- Cache heavily (`cache [@betting_pool, "leaderboard"]`)

### 3. Prediction Submission UX (SPA-like)
**Goal:** Smooth single-page experience for making predictions

- List all upcoming matches in a stage
- Inline forms for each match (no page reloads)
- Instant validation feedback
- "Save & Next" flow
- Show "X of Y predictions completed" progress
- Distinguish between:
  - Score prediction (football)
  - Winner selection (Oscars, knockout stages)

### 4. Development Initialization Script
**Goal:** Stop manually loading data on every DB reset

Create `lib/tasks/dev.rake`:
- Load 2026 World Cup structure (events, stages, matches)
- Load Oscar nominations (once implemented)
- Create sample users and betting pools
- Optionally: generate sample predictions for testing

**Not** in `db/seeds.rb` - this is dev-only data.

### 5. Update FIFA Event Importer
**Goal:** Adjust for new Event → Stage → Match structure

- Parse JSON to create Stages (Group Stage, Round of 16, etc.)
- Associate matches with correct stages
- Handle `round_number` if present in data
- Preserve existing import logic where possible

## Near-term Features (Next Month)

### 6. Oscars Event Importer
**Goal:** Support non-sports events

- Parse Oscar nominations HTML/JSON
- Create Event: "Academy Awards 2025"
- Create Stages: "Best Picture", "Best Actor", etc. (or single "Oscars" stage?)
- Create "Matches" (really: categories with nominees)
- Different prediction type: pick winner, not score
- **Question to resolve:** Are Oscar categories "stages" or something else?

### 7. Match Results Update Strategy
**Decision needed:** Manual admin form vs automated scraping?

**Option A: Manual Admin Interface**
- Simple form: select match, enter scores, mark as final
- Mobile-friendly (update from your phone during matches)
- Reliable, no API dependencies

**Option B: Automated Updates**
- Scrape from FIFA API or similar
- Background job checks every 15 minutes
- Fallback to manual if API fails

**Recommendation:** Start with A, add B later if needed.

### 8. Betting Windows & Stage Deadlines
**Goal:** Lock predictions before stages start

- Add `stages.betting_deadline` (DateTime)
- Validate predictions can't be created/edited after deadline
- Show countdown timers in UI
- Email reminders before deadline (future)

## Polish & Quality of Life (Before World Cup)

### 9. Mobile Experience
- Responsive design audit
- Touch-friendly forms
- PWA manifest for "add to home screen"
- Push notifications (future)

### 10. WhatsApp Integration
- Generate shareable leaderboard images
- Playoff bracket visualization
- "Share your predictions" feature

### 11. Public/Private Pools
- Add `betting_pools.visibility` (public/private)
- Join codes for private pools
- Public pool discovery page

### 12. Enhanced Analytics
- User stats dashboard (accuracy %, best stage, etc.)
- Pool statistics (most popular predictions, consensus picks)
- Historical performance tracking

## Technical Debt & Optimizations

### Caching Strategy
- Fragment caching: `cache [@betting_pool, "leaderboard"]`
- Russian doll caching for nested match/prediction views
- Low-level cache for expensive score calculations
- Cache invalidation on match result updates

### Performance
- Eager loading (`includes`) for N+1 query prevention
- Database indexes on frequently queried columns
- Background jobs for heavy calculations (Solid Queue)

### Testing
- Model validations and associations
- Score calculation edge cases
- Prediction deadline enforcement
- Integration tests for critical flows

## Future Enhancements (Post-Launch)

- Email notifications (match reminders, score updates)
- Social features (comments, trash talk)
- Multiple scoring schemes per pool
- Tournament bracket visualization
- Historical tournaments archive
- API for mobile apps

## Open Questions to Resolve

1. **Roles in memberships:** Do we need `role` (admin/member) or just check `creator_id`?
   - **Recommendation:** Remove role, use `creator_id` only. YAGNI.

2. **Oscar categories as stages?** How do we model non-match events?
   - Each category could be a "stage" with one "match" per nominee?
   - Or separate Event type with different prediction model?

3. **Score field on predictions:** Should predictions track their own score?
   - **Recommendation:** Yes - helpful for debugging, audit trail, and "this prediction earned X points"

4. **Match updating frequency:** Real-time scraping or manual updates?
   - **Recommendation:** Start manual, automate later if needed

5. **Betting pool scope:** Should pools span multiple events/stages?
   - **Current:** Pool belongs_to Event (covers all stages)
   - **Future:** Add optional `stage_id` for stage-specific pools
   - **Way Future:** has_many :matches for arbitrary match selection
