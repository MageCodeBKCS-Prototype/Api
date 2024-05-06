class AddCodeQlStatusToReports < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :codeql_status, :integer, default: 0
  end
end
