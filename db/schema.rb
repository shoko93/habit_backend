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

ActiveRecord::Schema[7.0].define(version: 2023_09_09_093909) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "post_bookmarks", force: :cascade do |t|
    t.text "line_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "post_comments", force: :cascade do |t|
    t.integer "post_id"
    t.text "comment"
    t.text "line_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "post_likes", force: :cascade do |t|
    t.text "line_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text "line_id"
    t.text "title"
    t.text "text_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts_tags", force: :cascade do |t|
    t.integer "post_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.text "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.text "line_id", null: false
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_id"], name: "index_users_on_line_id", unique: true
  end

  add_foreign_key "post_bookmarks", "posts"
  add_foreign_key "post_comments", "posts"
  add_foreign_key "post_comments", "users", column: "line_id", primary_key: "line_id"
  add_foreign_key "post_likes", "posts"
  add_foreign_key "posts", "users", column: "line_id", primary_key: "line_id"
  add_foreign_key "posts_tags", "posts"
  add_foreign_key "posts_tags", "tags"
end
