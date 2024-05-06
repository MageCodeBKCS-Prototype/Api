class ReportFilesController < ApplicationController
    before_action :set_report, only: %i[show]

    # GET /report_files/1
    def show
        render json: @report_file
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_report_filed
    @report_file = ReportFile.find(params[:id])
    end
end
