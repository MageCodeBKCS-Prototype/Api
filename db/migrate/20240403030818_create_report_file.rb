class CreateReportFile < ActiveRecord::Migration[7.1]
  def change
    create_table :report_files do |t|
      t.bigint :report_id, null: false
      t.string  :filename, null: false
      t.string  :programming_language, null: false
      t.float :machine_code_probability, null: false
      t.timestamps

      t.foreign_key :reports, column: :report_id

      t.index [:report_id, :filename], name: "report_files_report_filename"
    end
  end
end
