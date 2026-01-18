Great project! The 2026 World Cup starts June 11th, so you have about 5 months - plenty of time. Here's a roadmap for today (Sunday afternoon):

## Today's To-Do List (1pm - evening)

### Phase 1: Project Setup & Core Models (2-3 hours)
1. **Initialize Rails 8 app**
   - `rails new worldcup_pool --css=tailwind`
   - Set up git repo
   - Configure database (PostgreSQL recommended for production)

2. **Design & create core models**
   - `Match` (team1, team2, score1, score2, match_date, stage, group)
   - `Prediction` (user_id, match_id, predicted_score1, predicted_score2)
   - `User` (name, email, phone for WhatsApp notifications later)
   - Run migrations

3. **Seed initial World Cup data**
   - Load the 104 matches schedule (groups + knockouts)
   - You can grab this from FIFA's site or an API later

### Phase 2: Basic Match Updates Flow (2-3 hours)
4. **Build match admin interface**
   - Simple form to update match scores
   - Authentication (just basic HTTP auth for now - it's only you)
   - List view of today's/upcoming matches

5. **Implement scoring logic**
   - Exact score = 5 points
   - Correct winner/draw = 3 points
   - Calculate after each match update
   - Create a `Leaderboard` service object

### Phase 3: Caching Strategy (1 hour)
6. **Set up Rails 8 caching**
   - Fragment caching for leaderboard (`cache @leaderboard`)
   - Russian doll caching for match results
   - Add cache invalidation on match score updates
   - Low-level cache for expensive calculations

### If Time Permits:
7. **Basic public views**
   - Leaderboard page (cached heavily)
   - Upcoming matches
   - User's own predictions view

## Next Session Priorities:
- Prediction submission interface
- WhatsApp image generation (screenshotting leaderboard with Playwright/Puppeteer)
- PWA manifest & service worker
- Deploy to your weak server with solid caching

## Quick Wins for Your Pain Points:
- **Real-time updates**: Build a simple admin form you can access from your phone - 30 seconds to update a score
- **Leaderboard images**: Later we'll add an endpoint that generates a PNG of the leaderboard automatically, ready to share
- **Caching**: With proper caching, even a weak server can handle 50 concurrent users refreshing constantly

Want to start with the Rails setup, or do you already have a project initialized?