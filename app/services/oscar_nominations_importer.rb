require "nokogiri"

class OscarNominationsImporter
  STAGE_NAME = "98th Academy Awards Ceremony"
  EVENT_NAME = "98th Academy Awards"
  CEREMONY_DATE = Date.new(2026, 3, 15) # Placeholder date for the ceremony

  def initialize(html_content)
    @doc = Nokogiri::HTML(html_content)
    @stats = {
      event: nil,
      stages_created: 0,
      participants_created: 0,
      participants_updated: 0,
      matches_created: 0,
      match_participants_created: 0
    }
  end

  def import!
    ActiveRecord::Base.transaction do
      create_event
      create_stage
      import_categories
    end
    @stats
  end

  private

  def create_event
    @event = Event.find_or_initialize_by(name: EVENT_NAME)

    if @event.new_record?
      @event.assign_attributes(
        description: "The 98th Academy Awards ceremony honoring the best films of 2025",
        start_date: CEREMONY_DATE,
        end_date: CEREMONY_DATE
      )
      @event.save!
      @stats[:event] = "created"
    else
      @stats[:event] = "updated"
    end
  end

  def create_stage
    @stage = Stage.find_or_initialize_by(name: STAGE_NAME, event: @event)

    if @stage.new_record?
      @stage.save!
      @stats[:stages_created] += 1
    end
  end

  def import_categories
    categories = extract_categories
    categories.each_with_index do |category, index|
      import_category(category, index + 1)
    end
  end

  def extract_categories
    categories = []

    # Find all category header divs (they have the yellow background)
    @doc.css("div[style*='#F9EFAA']").each do |header_div|
      category_name = header_div.css("b a").text.strip
      next if category_name.empty?

      # Find the parent td and get the ul with nominees
      parent_td = header_div.parent
      nominees_ul = parent_td.css("ul").first
      next unless nominees_ul

      nominees = extract_nominees(nominees_ul, category_name)

      categories << {
        name: category_name,
        nominees: nominees
      }
    end

    categories
  end

  def extract_nominees(ul_element, category_name)
    nominees = []

    ul_element.css("li").each do |li|
      nominee_name = extract_nominee_name(li, category_name)
      next if nominee_name.blank?

      nominees << { name: nominee_name }
    end

    nominees
  end

  def extract_nominee_name(li_element, category_name)
    # Different categories have different formats:
    # - Best Picture: Film title is in <i><a>
    # - Best Director/Actor/Actress: Person name is the first <a> tag
    # - Best Original Song: Song title in quotes, then "from Film"

    case category_name
    when /Picture|Animated Feature|Documentary|International|Short/i
      # Film-based categories: extract the film title from <i><a>
      film_link = li_element.css("i a").first
      film_link&.text&.strip
    when /Song/i
      # Song category: extract song name from the beginning (in quotes)
      text = li_element.text.strip
      match = text.match(/^"([^"]+)"/)
      match ? match[1] : text.split("–").first&.strip
    else
      # Person-based categories (Director, Actor, Actress, etc.): first <a> is the person
      first_link = li_element.css("a").first
      first_link&.text&.strip
    end
  end

  def import_category(category, round_number)
    # Create participants for all nominees first
    category[:nominees].each do |nominee_data|
      find_or_create_participant(nominee_data[:name])
    end

    # Create the match (category)
    match = Match.find_or_initialize_by(
      stage: @stage,
      round: round_number
    )

    is_new = match.new_record?

    match.assign_attributes(
      match_date: CEREMONY_DATE.to_datetime,
      match_type: :multi_nominee
    )

    # Save without validation first to get an ID, then add participants
    match.save!(validate: false)

    # Create match participants for each nominee
    category[:nominees].each do |nominee_data|
      participant = Participant.find_by(name: nominee_data[:name])
      next unless participant

      mp = MatchParticipant.find_or_initialize_by(
        match: match,
        participant: participant
      )

      if mp.new_record?
        mp.save!
        @stats[:match_participants_created] += 1
      end
    end

    # Save again to trigger validations and status assignment
    match.save!

    if is_new
      @stats[:matches_created] += 1
    end
  end

  def find_or_create_participant(name)
    return nil if name.blank?

    participant = Participant.find_or_initialize_by(name: name)

    if participant.new_record?
      participant.save!
      @stats[:participants_created] += 1
    else
      @stats[:participants_updated] += 1
    end

    participant
  end
end
