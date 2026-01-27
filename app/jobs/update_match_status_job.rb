class UpdateMatchStatusJob < ApplicationJob
  queue_as :default

  def perform
    update_pending_matches
  end

  private

  def update_pending_matches
    Match.where(match_status: [ :bets_open, :bets_closed ]).find_each do |match|
      match.save # Triggers assign_lifecycle_status callback
    end
  end
end
