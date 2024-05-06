# == Schema Information
#
# Table name: reports
#
#  id                         :bigint           not null, primary key
#  codeql_status              :integer          default("codeql_processing")
#  error                      :text(65535)
#  exit_status                :integer
#  machine_code_detect_status :integer          default("detection_processing")
#  memory                     :integer
#  run_time                   :float(24)
#  status                     :integer
#  stderr                     :text(65535)
#  stdout                     :text(65535)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  dataset_id                 :bigint           not null
#
# Indexes
#
#  index_reports_on_dataset_id  (dataset_id)
#
require 'csv'

class Report < ApplicationRecord
  belongs_to :dataset
  has_many  :report_file

  AUTOMATICALLY_DELETE_AFTER = 30.days
  AUTOMATICALLY_DELETE_UNZIPPED_AFTER = 5.minutes

  RESULT_FILES = {
    'metadata.csv' => :metadata,
    'files.csv' => :files,
    'kgrams.csv' => :kgrams,
    'pairs.csv' => :pairs
  }.freeze

  CODEQL_RESULT_FILES = 'codeql.csv'.freeze

  has_one_attached :metadata
  has_one_attached :files
  has_one_attached :kgrams
  has_one_attached :pairs
  has_one_attached :codeql

  enum :status, { unknown: 0, queued: 1, running: 2, failed: 3, error: 4, finished: 5, purged: 6 }
  enum :machine_code_detect_status, { detection_processing: 0, detection_finished: 1 }
  enum :codeql_status, { codeql_processing: 0, codeql_success: 1, codeql_failed: 2 }

  validates_associated :dataset, on: :create
  accepts_nested_attributes_for :dataset

  after_create :queue_analysis

  delegate :name, to: :dataset

  def html_url
    "#{Rails.configuration.front_end_base_url}#{Rails.configuration.front_end_html_path}#{id}"
  end

  def queue_analysis
    return if finished?

    update(status: :queued)
    AnalyzeDatasetJob.perform_later(self)

    # Automatic cleanup is currently disabled
    # delay(run_at: AUTOMATICALLY_DELETE_AFTER.from_now).purge_files!
    delay(run_at: AUTOMATICALLY_DELETE_UNZIPPED_AFTER.from_now).delete_unzipped_files
  end

  def all_files_present?
    RESULT_FILES.values.all? { |attachment| send(attachment).attached? }
  end

  def attachment_by_filename(file)
    if file == CODEQL_RESULT_FILES
      name = :codeql
    else
      name = RESULT_FILES[file]
      raise ActiveRecord::RecordNotFound, 'Result file not found' if name.nil? || !send(name).attached?
    end

    send(name)
  end

  def collect_files_from(result_dir)
    read_programming_language = dataset.programming_language.nil?

    RESULT_FILES.map do |file, name|
      path = result_dir.join(file)
      next unless File.readable?(path)

      if name == :metadata && read_programming_language
        lang = CSV.read(path).filter_map { |k, v, _| v if k == 'language' }.first
        dataset.update(programming_language: lang)
      end

      send(name).attach(
        io: File.open(path),
        filename: file,
        content_type: 'text/csv',
        identify: false
      )
    end
  end

  def collect_codeql_file(result_dir)
    path = Pathname.new(result_dir).join(CODEQL_RESULT_FILES)
    raise ActiveStorage::FileNotFoundError, "CodeQL result file not found at path: #{result_dir}" unless File.readable?(path)

    send(:codeql).attach(
      io: File.open(path),
      filename: CODEQL_RESULT_FILES,
      content_type: 'text/csv',
      identify: false
    )
  end

  def purge_files!
    return if purged?

    RESULT_FILES.each_value do |name|
      attachment = send(name)
      attachment.purge if attachment.attached?
    end

    dataset.purge_files!

    update(status: :purged)
  end

  def delete_unzipped_files
    if detection_finished? && (codeql_success? || codeql_failed?)
      unzip_path = File.join(Rails.application.config.unzip_location, dataset.id.to_s)
      FileUtils.rm_rf(unzip_path) if File.directory?(unzip_path)
      return
    end

    delay(run_at: AUTOMATICALLY_DELETE_UNZIPPED_AFTER.from_now).delete_unzipped_files
  end
end
