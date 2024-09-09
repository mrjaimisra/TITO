# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_09_09_064442) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changed_files", force: :cascade do |t|
    t.string "file_path"
    t.string "file_name"
    t.integer "additions"
    t.integer "deletions"
    t.integer "number_of_changes"
    t.integer "total_line_length"
    t.decimal "total_flog_score"
    t.decimal "average_flog_score_per_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
