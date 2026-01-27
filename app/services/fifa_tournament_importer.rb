class FifaTournamentImporter
  def initialize(json_data)
    @data = json_data
    @stats = {
      event: nil,
      stages_created: 0,
      stages_updated: 0,
      participants_created: 0,
      participants_updated: 0,
      matches_created: 0,
      matches_updated: 0
    }
  end

  def import!
    ActiveRecord::Base.transaction do
      create_or_update_event
      import_stages
      import_participants
      import_matches
    end
    @stats
  end

  private

  def create_or_update_event
    # Extract tournament info from first match
    first_match = @data["Results"].first
    tournament_name = first_match["SeasonName"].first["Description"]

    # Find dates from all matches
    all_dates = @data["Results"].map { |m| Date.parse(m["Date"]) }

    @event = Event.find_or_initialize_by(name: tournament_name)

    if @event.new_record?
      @event.assign_attributes(
        description: first_match["CompetitionName"].first["Description"],
        start_date: all_dates.min,
        end_date: all_dates.max
      )
      @event.save!
      @stats[:event] = "created"
    else
      @event.update!(
        start_date: all_dates.min,
        end_date: all_dates.max
      )
      @stats[:event] = "updated"
    end
  end

  def import_stages
    stages = extract_unique_stages

    stages.each do |stage_data|
      stage = Stage.find_or_initialize_by(name: stage_data[:name], event: @event)

      if stage.new_record?
        stage.save!
        @stats[:stages_created] += 1
      else
        @stats[:stages_updated] += 1
      end
    end
  end

  def import_participants
    teams = extract_unique_teams

    teams.each do |team_data|
      participant = Participant.find_or_initialize_by(name: team_data[:name])

      if participant.new_record?
        participant.save!
        @stats[:participants_created] += 1
      else
        @stats[:participants_updated] += 1
      end
    end
  end

  def import_matches
    @data["Results"].each do |match_data|
      # Skip matches without both teams defined yet (playoffs, etc)
      home_team = match_data["Home"]
      away_team = match_data["Away"]

      # Extract match date
      match_date = DateTime.parse(match_data["Date"])

      stage = Stage.find_by!(event: @event, name: match_data["StageName"].first["Description"])

      # Find or create match by event + date + round
      # Using round (MatchNumber) as unique identifier within event
      match = Match.find_or_initialize_by(
        stage: stage,
        round: match_data["MatchNumber"],
        match_type: :one_on_one
      )

      is_new = match.new_record?

      match.assign_attributes(
        match_date: match_date
      )

      match.save!

      # Create match participants if teams are known
      if home_team && home_team["TeamName"]
        create_match_participant(match, home_team["TeamName"].first["Description"])
      end

      if away_team && away_team["TeamName"]
        create_match_participant(match, away_team["TeamName"].first["Description"])
      end

      match.save!  # Triggers before_validation to set status based on participants

      if is_new
        @stats[:matches_created] += 1
      else
        @stats[:matches_updated] += 1
      end
    end
  end

  def extract_unique_stages
    stages = []

    @data["Results"].each do |match|
      if match["StageName"]
        stages << {
          name: match["StageName"].first["Description"]
        }
      end
    end

    stages.uniq { |t| t[:name] }
  end

  def extract_unique_teams
    teams = []

    @data["Results"].each do |match|
      if match["Home"] && match["Home"]["TeamName"]
        teams << {
          name: match["Home"]["TeamName"].first["Description"]
        }
      end

      if match["Away"] && match["Away"]["TeamName"]
        teams << {
          name: match["Away"]["TeamName"].first["Description"]
        }
      end
    end

    teams.uniq { |t| t[:name] }
  end

  def create_match_participant(match, team_name)
    participant = Participant.find_by(name: team_name)
    return unless participant

    MatchParticipant.find_or_create_by!(
      match: match,
      participant: participant
    )
  end
end
