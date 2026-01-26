# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
print "Seeding primary database"
user = User.find_or_create_by!(email_address: Rails.application.credentials.dig("seed_user", "email_address")) do |user|
  user.password = Rails.application.credentials.dig("seed_user", "password")
  user.name = Rails.application.credentials.dig("seed_user", "name")
  user.admin = true
end
print "."

the_time = Time.current

event = Event.find_or_create_by!(name: "Fifa world Cup") do |event|
  event.description = "It's the world cup!"
  event.start_date = the_time
  event.end_date = the_time
end
print "."

stage = Stage.find_or_create_by!(name: "Final") do |stage|
  stage.event = event
end

participants = [ "France", "Argentina" ].map do |country|
  Participant.find_or_create_by!(name: country)
end
print "."

match = Match.find_or_create_by!(id: 1) do |match|
  match.match_date = the_time
  match.round = 1
  match.stage = stage
  match.participants = participants
  match.match_status = :bets_open
end
print "."

match.match_participants.find_each do |m_participant|
  Result.find_or_create_by(match_participant_id: m_participant.id) do |result|
    result.score = 2
    result.final = true
  end
end
print "."

betting_pool = BettingPool.find_or_create_by!(name: "Primer Pollyto", event: event) do |pool|
  pool.creator = user
  pool.is_public = true
end
print "."

# Create a prediction for the user
prediction = Prediction.find_or_create_by!(
  user: user,
  betting_pool: betting_pool,
  match: match
)
print "."

# Create predicted results for each participant
match.match_participants.find_each do |m_participant|
  PredictedResult.find_or_create_by!(
    prediction: prediction,
    match_participant: m_participant
  ) do |predicted_result|
    predicted_result.score = 3  # User predicted 3-3
  end
end

puts " Success!"
