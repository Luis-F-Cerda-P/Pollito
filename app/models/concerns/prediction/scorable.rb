module Prediction::Scorable
  # TODO: Make this whole process be scoped to a specific betting pool, so reports can be sent when each betting pool has been recalculated

  # One-on-one scoring
  EXACT_SCORE_POINTS = 2
  CORRECT_OUTCOME_POINTS = 2

  # Multi-nominee scoring
  CORRECT_WINNER_POINTS = 2

  def calculate_score!
    return unless match.finished?

    transaction do
      if match.multi_nominee?
        calculate_multi_nominee_score!
      else
        calculate_one_on_one_score!
      end
      update_membership_scores!
    end
  end

  private

  def calculate_one_on_one_score!
    calculate_participant_scores!
    calculate_outcome_points!
    calculate_total_score!
  end

  def calculate_multi_nominee_score!
    # For multi-nominee: only award points for picking the correct winner
    actual_winner_mp_id = match.outcome
    predicted_winner_mp_id = predicted_outcome

    points = (actual_winner_mp_id == predicted_winner_mp_id) ? CORRECT_WINNER_POINTS : 0

    # Clear any participant-level points (not used for multi-nominee)
    predicted_results.update_all(points: 0)

    # Store as outcome_points and total_points
    update!(outcome_points: points, total_points: points)
  end

  def calculate_participant_scores!
    # Check if all predicted scores match actual results exactly
    all_scores_correct = predicted_results.all? do |predicted_result|
      actual_result = match.results.find_by(
        match_participant_id: predicted_result.match_participant_id
      )
      actual_result && predicted_result.score == actual_result.score
    end

    # Award points only if ALL scores are exactly correct
    if all_scores_correct && predicted_results.any?
      predicted_results.first.update!(points: EXACT_SCORE_POINTS)
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
