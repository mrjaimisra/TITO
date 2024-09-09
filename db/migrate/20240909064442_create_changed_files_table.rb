class CreateChangedFilesTable < ActiveRecord::Migration[7.2]
  def change
    create_table :changed_files do |t|
      t.string :file_path
      t.string :file_name
      t.integer :additions
      t.integer :deletions
      t.integer :number_of_changes
      t.integer :total_line_length
      t.decimal :total_flog_score
      t.decimal :average_flog_score_per_method
    end
  end
end
