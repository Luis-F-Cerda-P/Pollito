require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "assigns bets_open status when match has participants and betting is open" do
    match = matches(:brazil_vs_argentina)
    match.match_date = 2.days.from_now
    match.save!

    assert_equal "bets_open", match.match_status
  end

  test "assigns bets_closed status when betting cutoff has passed" do
    match = matches(:brazil_vs_argentina)
    match.match_date = 6.hours.from_now # Within the 12-hour cutoff
    match.save!

    assert_equal "bets_closed", match.match_status
  end

  test "assigns in_progress status when match_date has passed" do
    match = matches(:brazil_vs_argentina)
    match.match_date = 1.hour.ago
    match.save!

    assert_equal "in_progress", match.match_status
  end

  test "does not change status from in_progress when saved" do
    match = matches(:brazil_vs_argentina)
    match.match_status = :in_progress
    match.save!(validate: false) # Skip validation to set initial state

    match.match_date = 2.days.from_now
    match.save!

    assert_equal "in_progress", match.match_status
  end

  test "does not change status from finished when saved" do
    match = matches(:brazil_vs_argentina)
    match.match_status = :finished
    match.save!(validate: false) # Skip validation to set initial state

    match.match_date = 2.days.from_now
    match.save!

    assert_equal "finished", match.match_status
  end

  test "assigns unset status when match has no participants" do
    stage = stages(:group_stage)
    match = Match.new(
      stage: stage,
      match_date: 2.days.from_now,
      match_type: :one_on_one,
      round: 1
    )
    match.save!

    assert_equal "unset", match.match_status
  end
end
