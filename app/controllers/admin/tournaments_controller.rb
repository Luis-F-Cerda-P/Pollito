class Admin::TournamentsController < ApplicationController
  before_action :require_admin!

  def import
    # GET - shows upload form
  end

  def create_from_json
    # POST - processes uploaded JSON file
    unless params[:json_file].present?
      @error = "No file uploaded"
      return respond_to do |format|
        format.html { render :import, status: :unprocessable_entity }
        format.json { render json: { error: @error }, status: :unprocessable_entity }
      end
    end

    file = params[:json_file]
    json_data = JSON.parse(file.read)

    importer = FifaTournamentImporter.new(json_data)
    @stats = importer.import!
    @success = true

    respond_to do |format|
      format.html { render :import }
      format.json {
        render json: {
          message: "Tournament imported successfully",
          stats: @stats
        }, status: :created
      }
    end
  rescue JSON::ParserError => e
    @error = "Invalid JSON: #{e.message}"
    respond_to do |format|
      format.html { render :import, status: :unprocessable_entity }
      format.json { render json: { error: @error }, status: :unprocessable_entity }
    end
  rescue StandardError => e
    @error = e.message
    respond_to do |format|
      format.html { render :import, status: :internal_server_error }
      format.json { render json: { error: @error }, status: :internal_server_error }
    end
  end
end
