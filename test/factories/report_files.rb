# == Schema Information
#
# Table name: report_files
#
#  id                       :bigint           not null, primary key
#  filename                 :string(255)      not null
#  machine_code_probability :float(24)        not null
#  programming_language     :string(255)      not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  report_id                :bigint           not null
#
# Indexes
#
#  report_files_report_filename  (report_id,filename)
#
# Foreign Keys
#
#  fk_rails_...  (report_id => reports.id) ON DELETE => cascade ON UPDATE => cascade
#
FactoryBot.define do
  factory :report_file do
    
  end
end
