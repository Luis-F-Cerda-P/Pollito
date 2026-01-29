require "test_helper"

class Prediction::ScorableTest < ActiveSupport::TestCase
  setup do
    @user = users(:regular_user)
    @betting_pool = betting_pools(:private_pool)
    @match = matches(:brazil_vs_argentina)
    @brazil_mp = match_participants(:brazil_in_match)
    @argentina_mp = match_participants(:argentina_in_match)

    # Ensure user is a member of the pool
    @betting_pool.betting_pool_memberships.find_or_create_by!(user: @user)

    # Set match to a future date so we can create predictions
    @match.update_columns(match_date: 2.days.from_now, match_status: :bets_open)
  end

  # === One-on-One: Exact Score Tests ===

  test "awards 2 points when all scores are exactly correct" do
    # Actual result: Brazil 2, Argentina 1
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 2, Argentina 1 (exact match)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    assert_equal 2, prediction.predicted_results.sum(:points), "Should award 2 points for exact score match"
  end

  test "awards 0 points when one score is wrong" do
    # Actual result: Brazil 2, Argentina 2
    create_results(@brazil_mp => 2, @argentina_mp => 2)

    # Prediction: Brazil 2, Argentina 1 (one score wrong)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    assert_equal 0, prediction.predicted_results.sum(:points), "Should award 0 points when any score is wrong"
  end

  test "awards 0 points when all scores are wrong" do
    # Actual result: Brazil 3, Argentina 0
    create_results(@brazil_mp => 3, @argentina_mp => 0)

    # Prediction: Brazil 1, Argentina 2 (both wrong)
    prediction = create_prediction(@brazil_mp => 1, @argentina_mp => 2)

    finalize_and_score!

    prediction.reload
    assert_equal 0, prediction.predicted_results.sum(:points), "Should award 0 points when all scores are wrong"
  end

  # === One-on-One: Outcome Tests ===

  test "awards 2 outcome points for correctly predicting a win" do
    # Actual result: Brazil 2, Argentina 1 (Brazil wins)
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 3, Argentina 0 (wrong scores, but Brazil wins)
    prediction = create_prediction(@brazil_mp => 3, @argentina_mp => 0)

    finalize_and_score!

    prediction.reload
    assert_equal 2, prediction.outcome_points, "Should award 2 points for correct outcome"
  end

  test "awards 2 outcome points for correctly predicting a draw" do
    # Actual result: Brazil 1, Argentina 1 (draw)
    create_results(@brazil_mp => 1, @argentina_mp => 1)

    # Prediction: Brazil 2, Argentina 2 (wrong scores, but still a draw)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 2)

    finalize_and_score!

    prediction.reload
    assert_equal 2, prediction.outcome_points, "Should award 2 points for correctly predicting draw"
  end

  test "awards 0 outcome points for wrong outcome" do
    # Actual result: Brazil 2, Argentina 1 (Brazil wins)
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 0, Argentina 1 (Argentina wins - wrong outcome)
    prediction = create_prediction(@brazil_mp => 0, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    assert_equal 0, prediction.outcome_points, "Should award 0 points for wrong outcome"
  end

  test "awards 0 outcome points when predicting win but result is draw" do
    # Actual result: Brazil 1, Argentina 1 (draw)
    create_results(@brazil_mp => 1, @argentina_mp => 1)

    # Prediction: Brazil 2, Argentina 1 (Brazil wins - wrong outcome)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    assert_equal 0, prediction.outcome_points, "Should award 0 points when predicting win but result is draw"
  end

  # === One-on-One: Total Points Tests ===

  test "calculates correct total for exact score and correct outcome" do
    # Actual result: Brazil 2, Argentina 1
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 2, Argentina 1 (perfect prediction)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    # 2 for exact scores + 2 for correct outcome = 4
    assert_equal 4, prediction.total_points, "Should award 4 total points for perfect prediction"
  end

  test "calculates correct total for wrong scores but correct outcome" do
    # Actual result: Brazil 2, Argentina 1
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 3, Argentina 0 (wrong scores, correct outcome)
    prediction = create_prediction(@brazil_mp => 3, @argentina_mp => 0)

    finalize_and_score!

    prediction.reload
    # 0 for exact scores + 2 for correct outcome = 2
    assert_equal 2, prediction.total_points, "Should award 2 points for correct outcome only"
  end

  test "exact scores always imply correct outcome" do
    # If both scores are exact, the outcome must also be correct
    # This is a logical constraint - verify it holds
    create_results(@brazil_mp => 2, @argentina_mp => 1)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    finalize_and_score!

    prediction.reload
    # Exact scores (2 points) must come with correct outcome (2 points)
    assert_equal 2, prediction.predicted_results.sum(:points)
    assert_equal 2, prediction.outcome_points
  end

  test "calculates zero total for wrong scores and wrong outcome" do
    # Actual result: Brazil 2, Argentina 1
    create_results(@brazil_mp => 2, @argentina_mp => 1)

    # Prediction: Brazil 0, Argentina 3 (all wrong)
    prediction = create_prediction(@brazil_mp => 0, @argentina_mp => 3)

    finalize_and_score!

    prediction.reload
    assert_equal 0, prediction.total_points, "Should award 0 points for completely wrong prediction"
  end

  # === Multi-Nominee Tests ===

  test "multi-nominee: awards 2 points for correct winner" do
    stage = stages(:group_stage)
    multi_match = Match.create!(
      stage: stage,
      match_date: 2.days.from_now,
      match_type: :multi_nominee,
      round: 1
    )

    nominee1 = Participant.create!(name: "Nominee 1")
    nominee2 = Participant.create!(name: "Nominee 2")
    nominee3 = Participant.create!(name: "Nominee 3")

    mp1 = multi_match.match_participants.create!(participant: nominee1)
    mp2 = multi_match.match_participants.create!(participant: nominee2)
    mp3 = multi_match.match_participants.create!(participant: nominee3)

    multi_match.reload

    # Actual result: Nominee 1 wins
    mp1.create_result!(score: 1)
    mp2.create_result!(score: 0)
    mp3.create_result!(score: 0)

    # Prediction: Nominee 1 wins
    prediction = Prediction.create!(
      betting_pool: @betting_pool,
      match: multi_match,
      user: @user
    )
    prediction.predicted_results.create!(match_participant: mp1, score: 1)
    prediction.predicted_results.create!(match_participant: mp2, score: 0)
    prediction.predicted_results.create!(match_participant: mp3, score: 0)

    multi_match.mark_as_final!

    prediction.reload
    assert_equal 2, prediction.total_points, "Should award 2 points for correct winner in multi-nominee"
    assert_equal 2, prediction.outcome_points
  end

  test "multi-nominee: awards 0 points for wrong winner" do
    stage = stages(:group_stage)
    multi_match = Match.create!(
      stage: stage,
      match_date: 2.days.from_now,
      match_type: :multi_nominee,
      round: 1
    )

    nominee1 = Participant.create!(name: "Nominee A")
    nominee2 = Participant.create!(name: "Nominee B")

    mp1 = multi_match.match_participants.create!(participant: nominee1)
    mp2 = multi_match.match_participants.create!(participant: nominee2)

    multi_match.reload

    # Actual result: Nominee 1 wins
    mp1.create_result!(score: 1)
    mp2.create_result!(score: 0)

    # Prediction: Nominee 2 wins (wrong)
    prediction = Prediction.create!(
      betting_pool: @betting_pool,
      match: multi_match,
      user: @user
    )
    prediction.predicted_results.create!(match_participant: mp1, score: 0)
    prediction.predicted_results.create!(match_participant: mp2, score: 1)

    multi_match.mark_as_final!

    prediction.reload
    assert_equal 0, prediction.total_points, "Should award 0 points for wrong winner in multi-nominee"
    assert_equal 0, prediction.outcome_points
  end

  # === Edge Cases ===

  test "does not calculate score for non-finished match" do
    create_results(@brazil_mp => 2, @argentina_mp => 1)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    # Don't finalize the match
    prediction.calculate_score!

    prediction.reload
    assert_nil prediction.total_points, "Should not calculate score for non-finished match"
  end

  test "updates betting pool membership score after calculation" do
    create_results(@brazil_mp => 2, @argentina_mp => 1)
    prediction = create_prediction(@brazil_mp => 2, @argentina_mp => 1)

    membership = @betting_pool.betting_pool_memberships.find_by(user: @user)
    membership.update!(score: 0) # Ensure score starts at 0

    finalize_and_score!

    membership.reload
    assert_equal 4, membership.score, "Membership score should equal prediction total points"
  end

  private

  def create_results(scores)
    scores.each do |match_participant, score|
      match_participant.create_result!(score: score)
    end
  end

  def create_prediction(scores)
    prediction = Prediction.create!(
      betting_pool: @betting_pool,
      match: @match,
      user: @user
    )

    scores.each do |match_participant, score|
      prediction.predicted_results.create!(
        match_participant: match_participant,
        score: score
      )
    end

    prediction
  end

  def finalize_and_score!
    @match.mark_as_final!
  end
end
