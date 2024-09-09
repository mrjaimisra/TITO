# class CreateChangedFilesTable < ActiveRecord::Migration[7.2]
#   def change
#     create_table :changed_files do |t|
#       t.integer :additions
#       t.integer :deletions
#       t.integer :number_of_changes
#       t.integer :total_line_length
#       t.total_flog_score,
#       t.average_flog_score_per_method,
#     end
#   end
# end
