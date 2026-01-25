module Prediction::Scorable
  # TODO: Make this whole process be scoped to a specific betting pool, so reports can be sent when each betting pool has been recalculated
  EXACT_SCORE_POINTS = 2
  CORRECT_OUTCOME_POINTS = 3

  def calculate_score!
    return unless match.finished?

    transaction do
      calculate_participant_scores!
      calculate_outcome_points!
      calculate_total_score!
      update_membership_scores!
    end
  end

  private

  def calculate_participant_scores!
    predicted_results.each do |predicted_result|
      actual_result = match.results.find_by(
        match_participant_id: predicted_result.match_participant_id
      )

      next unless actual_result && match.finished?

      points = predicted_result.score == actual_result.score ? EXACT_SCORE_POINTS : 0
      predicted_result.update!(points: points)
    end
  end

  def calculate_outcome_points!
    return unless match.finished?

    points = predicted_outcome == match.outcome ? CORRECT_OUTCOME_POINTS : 0
    update!(outcome_points: points)
  end

  def calculate_total_score!
    total = predicted_results.sum(:points) + (outcome_points || 0)
    update!(total_points: total)
  end

  def update_membership_scores!
    # Find all betting pools that include this match
    betting_pools = match.stage.event.betting_pools

    betting_pools.each do |pool|
      membership = pool.betting_pool_memberships.find_by(user: user)
      next unless membership

      membership.recalculate_total_score!
    end
  end
end
