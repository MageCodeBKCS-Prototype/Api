require 'net/http'

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show destroy data collect_codeql]
  # skip_before_action :authorized, only: %i[data collect_codeql]

  @sortable_fields = %w[name created_at status]

  def index
    user = current_user
    report_query = Report.joins(:dataset).where(dataset: { user_id: user.id })
    report_count = report_query.count

    begin
      sort_by = params.fetch(:sort_by, 'created_at').to_s
      sort_by = 'created_at' unless %w[name created_at status].include?(sort_by)
    rescue ArgumentError
      sort_by = 'created_at'
    end

    begin
      sort_direction = params.fetch(:sort_by, 'desc').to_s
      sort_direction = 'asc' unless %w[asc desc].include?(sort_direction)
    rescue ArgumentError
      sort_direction = 'asc'
    end

    report_query = report_query.order("#{sort_by} #{sort_direction}")

    begin
      page_size = params.fetch(:page_size, 10).to_i
    rescue ArgumentError
      page_size = 10
    end

    page_size = 10 if (page_size <= 0) || (page_size > report_count)
    page_count = (report_count / page_size) + 1

    begin
      current_page = params.fetch(:current_page, 1).to_i
    rescue ArgumentError
      current_page = 1
    end

    current_page = 1 if (current_page <= 0) || (current_page > page_count)
    offset = (current_page - 1) * page_size

    @reports = report_query.limit(page_size).offset(offset)
    report_json = @reports.as_json(include: :dataset)
    report_json.each do |report|
      report['id'] = report['id'].to_s
    end

    render json: {
      data_list: report_json,
      page_size: page_size,
      current_page: current_page,
      total: report_count
    }, status: :ok
  end

  # GET /reports/1
  def show
    if @report.dataset.user_id == @current_user.id
      render json: @report
    else
      render json: { message: 'Not found' }, status: :not_found
    end
  end

  # POST /reports
  def create
    @report = Report.new(dataset_attributes: dataset_params)
    @report.dataset.user_id = current_user.id
    if @report.save
      render json: @report, status: :created, location: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reports/1
  def destroy
    @report.purge_files!
    @report.destroy
  end

  # GET /reports/:id/data/:file
  def data
    if @report.dataset.user_id == @current_user.id
      attachment = @report.attachment_by_filename("#{params[:file]}.#{params[:format]}")
      redirect_to rails_blob_path(attachment, disposition: 'attachment')
    else
      render json: { message: 'Not found' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render status: :not_found
  end

  # POST /reports/:id/codeql
  def collect_codeql
    codeql_status = params[:status]
    result_dir = params[:result_dir]
    if codeql_status
      @report.collect_codeql_file(result_dir)
      @report.update(codeql_status: :codeql_success)
    else
      @report.update(codeql_status: :codeql_failed)
    end
    render status: :ok
  rescue ActiveRecord::RecordNotFound
    render status: :not_found
  rescue ActiveStorage::FileNotFoundError
    @report.update(codeql_status: :codeql_failed)
    render status: :unprocessable_entity
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_report
    @current_user = current_user
    @report = Report.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:zipfile, :name, :programming_language)
  end
end
