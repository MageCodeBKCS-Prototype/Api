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
class ReportSerializer < ApplicationSerializer
  attributes :error, :exit_status, :status, :stderr, :stdout, :name, :html_url, :machine_code_detect_status, :codeql_status

  has_one :dataset
  has_many :report_file
end
