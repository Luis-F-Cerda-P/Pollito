require "test_helper"

class UpdateMatchStatusJobTest < ActiveJob::TestCase
  test "transitions bets_open match to bets_closed when cutoff passes" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:bets_open])
    match.update_column(:match_date, 6.hours.from_now) # Within 12-hour cutoff

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "bets_closed", match.match_status
  end

  test "transitions bets_closed match to in_progress when match_date passes" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:bets_closed])
    match.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "in_progress", match.match_status
  end

  test "transitions bets_open match directly to in_progress when match_date passes" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:bets_open])
    match.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "in_progress", match.match_status
  end

  test "does not process unset matches" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:unset])
    match.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "unset", match.match_status
  end

  test "does not process in_progress matches" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:in_progress])
    match.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "in_progress", match.match_status
  end

  test "does not process finished matches" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:finished])
    match.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "finished", match.match_status
  end

  test "processes multiple matches in a single run" do
    match1 = matches(:brazil_vs_argentina)
    match2 = matches(:germany_vs_france)

    match1.update_column(:match_status, Match.match_statuses[:bets_open])
    match1.update_column(:match_date, 1.hour.ago)

    match2.update_column(:match_status, Match.match_statuses[:bets_closed])
    match2.update_column(:match_date, 1.hour.ago)

    UpdateMatchStatusJob.perform_now

    match1.reload
    match2.reload

    assert_equal "in_progress", match1.match_status
    assert_equal "in_progress", match2.match_status
  end

  test "leaves bets_open match unchanged when betting is still open" do
    match = matches(:brazil_vs_argentina)
    match.update_column(:match_status, Match.match_statuses[:bets_open])
    match.update_column(:match_date, 2.days.from_now)

    UpdateMatchStatusJob.perform_now

    match.reload
    assert_equal "bets_open", match.match_status
  end
end
