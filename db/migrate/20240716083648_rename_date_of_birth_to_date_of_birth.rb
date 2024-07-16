class RenameDateOfBirthToDateOfBirth < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :dateOfBirth, :date_of_birth
  end
end
