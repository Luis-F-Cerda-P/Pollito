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

# Create seed user
user = User.find_or_create_by!(email_address: Rails.application.credentials.dig("seed_user", "email_address")) do |u|
  u.password = Rails.application.credentials.dig("seed_user", "password")
  u.name = Rails.application.credentials.dig("seed_user", "name")
  u.admin = true
end
print "."

# Import tournament data from FIFA JSON
json_path = Rails.root.join("storage", "tournament.json")
json_data = JSON.parse(File.read(json_path))
importer = FifaTournamentImporter.new(json_data)
stats = importer.import!
print "."

puts "\n  Import stats: #{stats.inspect}"

# Get the imported event
event = Event.find_by!(name: "FIFA World Cup 2026™")
print "."

# Create betting pool for the event
betting_pool = BettingPool.find_or_create_by!(name: "Primer Pollyto", event: event) do |pool|
  pool.creator = user
  pool.is_public = true
end
print "."

# Create example predictions on the first 3 bettable matches
bettable_matches = event.matches.bets_open.order(:match_date).limit(3)
bettable_matches.each do |match|
  prediction = Prediction.find_or_create_by!(
    user: user,
    betting_pool: betting_pool,
    match: match
  )

  # Create predicted results with random scores (0-3)
  match.match_participants.each do |mp|
    PredictedResult.find_or_create_by!(
      prediction: prediction,
      match_participant: mp
    ) do |pr|
      pr.score = rand(0..3)
    end
  end
  print "."
end

puts " Success!"
