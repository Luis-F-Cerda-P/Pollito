# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.find_or_create_by!(email_address: Rails.application.credentials.dig("seed_user", "email_address")) do |user|
  user.password = Rails.application.credentials.dig("seed_user", "password")
  user.admin = true
end

the_time = Time.current

event = Event.find_or_create_by!(name: "Fifa world Cup") do |event|
  event.description = "It's the world cup!"
  event.start_date = the_time
  event.end_date = the_time
end

participants = [ "France", "Argentina" ].map do |country|
  Participant.find_or_create_by!(name: country)
end

Match.find_or_create_by!(id: 1) do |match|
  match.match_date = the_time
  match.round = 1
  match.event = event
  match.participants = participants
end
