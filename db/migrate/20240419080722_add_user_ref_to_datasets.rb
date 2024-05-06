class AddUserRefToDatasets < ActiveRecord::Migration[7.1]
  def change
    add_reference :datasets, :user, null: false, foreign_key: true, default: 8746177907326382093
  end
end
