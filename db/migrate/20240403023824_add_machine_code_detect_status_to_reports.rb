class AddMachineCodeDetectStatusToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :machine_code_detect_status, :integer, default: 0
  end
end
