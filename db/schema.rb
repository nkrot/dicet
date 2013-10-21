# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131021204237) do

  create_table "documents", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paradigm_tags", force: true do |t|
    t.integer  "paradigm_type_id"
    t.integer  "tag_id"
    t.integer  "order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paradigm_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paradigm_types", ["name"], name: "index_paradigm_types_on_name"

  create_table "paradigms", force: true do |t|
    t.string   "status"
    t.text     "comment"
    t.integer  "paradigm_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dumped",           default: false
    t.datetime "dumped_at"
    t.integer  "task_id"
  end

  add_index "paradigms", ["dumped"], name: "index_paradigms_on_dumped"
  add_index "paradigms", ["paradigm_type_id"], name: "index_paradigms_on_paradigm_type_id"
  add_index "paradigms", ["task_id"], name: "index_paradigms_on_task_id"

  create_table "sentence_tokens", force: true do |t|
    t.integer  "sentence_id"
    t.integer  "token_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sentence_tokens", ["sentence_id"], name: "index_sentence_tokens_on_sentence_id"
  add_index "sentence_tokens", ["token_id"], name: "index_sentence_tokens_on_token_id"

  create_table "sentences", force: true do |t|
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sentences", ["document_id"], name: "index_sentences_on_document_id"

  create_table "statistics", force: true do |t|
    t.integer "token_id"
    t.integer "corpus_freq"
    t.integer "number_docs"
    t.float   "cfnd"
    t.integer "upcased_corpus_freq"
    t.integer "upcased_number_docs"
    t.float   "upcased_cfnd"
  end

  add_index "statistics", ["token_id"], name: "index_statistics_on_token_id"

  create_table "tags", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name"

  create_table "tasks", force: true do |t|
    t.integer  "priority"
    t.string   "status"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["priority"], name: "index_tasks_on_priority"
  add_index "tasks", ["user_id", "priority"], name: "index_tasks_on_user_id_and_priority"
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id"

  create_table "tokens", force: true do |t|
    t.string   "text"
    t.string   "upcased_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["text"], name: "index_tokens_on_text"
  add_index "tokens", ["upcased_text"], name: "index_tokens_on_upcased_text"

  create_table "users", force: true do |t|
    t.string   "login"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password"
    t.string   "remember_token"
  end

  add_index "users", ["login"], name: "index_users_on_login"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "words", force: true do |t|
    t.string   "text"
    t.boolean  "typo"
    t.text     "comment"
    t.integer  "tag_id"
    t.integer  "paradigm_id"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "words", ["paradigm_id"], name: "index_words_on_paradigm_id"
  add_index "words", ["task_id"], name: "index_words_on_task_id"

end
