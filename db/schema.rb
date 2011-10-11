# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110921174528) do

  create_table "citations", :force => true do |t|
    t.text    "raw_string"
    t.text    "authors",         :default => "--- []"
    t.text    "title"
    t.integer "year"
    t.text    "publisher"
    t.text    "location"
    t.text    "booktitle"
    t.text    "journal"
    t.text    "pages"
    t.text    "volume"
    t.text    "number"
    t.text    "contexts",        :default => "--- []"
    t.text    "tech"
    t.text    "institution"
    t.text    "editor"
    t.text    "note"
    t.string  "marker_type"
    t.string  "marker"
    t.string  "rating"
    t.string  "uri"
    t.text    "original_string"
    t.text    "edition"
    t.text    "identifier"
    t.string  "md5_hash"
  end

  add_index "citations", ["md5_hash"], :name => "index_citations_on_md5_hash"
  add_index "citations", ["uri"], :name => "index_citations_on_uri"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tagged_references", :force => true do |t|
    t.text     "tagged_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",      :default => true
    t.integer  "citation_id"
  end

  add_index "tagged_references", ["citation_id"], :name => "index_tagged_references_on_citation_id"
  add_index "tagged_references", ["complete"], :name => "index_tagged_references_on_complete"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
