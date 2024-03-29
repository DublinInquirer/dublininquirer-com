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

ActiveRecord::Schema[7.0].define(version: 2022_07_19_213702) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "article_authors", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "author_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["article_id"], name: "index_article_authors_on_article_id"
    t.index ["author_id"], name: "index_article_authors_on_author_id"
  end

  create_table "articles", force: :cascade do |t|
    t.text "title", null: false
    t.text "slug", null: false
    t.text "excerpt"
    t.text "content"
    t.text "text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "featured_artwork_id"
    t.text "former_slugs", default: [], array: true
    t.text "template"
    t.boolean "featured", default: false
    t.text "category"
    t.bigint "issue_id"
    t.integer "position"
    t.bigint "tag_ids", default: [], array: true
    t.index "to_tsvector('english'::regconfig, category)", name: "articles_category", using: :gin
    t.index "to_tsvector('english'::regconfig, excerpt)", name: "articles_excerpt", using: :gin
    t.index "to_tsvector('english'::regconfig, text)", name: "articles_text", using: :gin
    t.index "to_tsvector('english'::regconfig, title)", name: "articles_title", using: :gin
    t.index ["category"], name: "index_articles_on_category"
    t.index ["featured_artwork_id"], name: "index_articles_on_featured_artwork_id"
    t.index ["former_slugs"], name: "index_articles_on_former_slugs"
    t.index ["issue_id"], name: "index_articles_on_issue_id"
    t.index ["position"], name: "index_articles_on_position"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["tag_ids"], name: "index_articles_on_tag_ids"
  end

  create_table "artworks", force: :cascade do |t|
    t.text "caption"
    t.text "image"
    t.text "hashed_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "article_id"
    t.integer "width_px"
    t.integer "height_px"
    t.index "to_tsvector('english'::regconfig, caption)", name: "artworks_caption", using: :gin
    t.index ["article_id"], name: "index_artworks_on_article_id"
    t.index ["hashed_id"], name: "index_artworks_on_hashed_id", unique: true
  end

  create_table "authors", force: :cascade do |t|
    t.text "full_name", null: false
    t.text "slug", null: false
    t.text "bio"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "portrait"
    t.index "to_tsvector('english'::regconfig, bio)", name: "authors_bio", using: :gin
    t.index "to_tsvector('english'::regconfig, full_name)", name: "authors_full_name", using: :gin
    t.index ["slug"], name: "index_authors_on_slug", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "article_id"
    t.bigint "parent_id"
    t.text "content"
    t.text "nickname"
    t.text "email_address"
    t.text "status"
    t.datetime "published_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "marked_as_spam", default: false
    t.index ["article_id"], name: "index_comments_on_article_id"
    t.index ["email_address"], name: "index_comments_on_email_address"
    t.index ["marked_as_spam"], name: "index_comments_on_marked_as_spam"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["status"], name: "index_comments_on_status"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.text "body"
    t.text "regarding"
    t.text "full_name"
    t.text "email_address"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email_address"], name: "index_contact_messages_on_email_address"
    t.index ["regarding"], name: "index_contact_messages_on_regarding"
  end

  create_table "election_surveys", force: :cascade do |t|
    t.text "slug"
    t.text "election_type"
    t.integer "election_year"
    t.jsonb "candidates", default: {}, null: false
    t.jsonb "responses", default: {}, null: false
    t.jsonb "questions", default: {}, null: false
    t.jsonb "parties", default: {}, null: false
    t.jsonb "areas", default: {}, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["areas"], name: "index_election_surveys_on_areas", using: :gin
    t.index ["candidates"], name: "index_election_surveys_on_candidates", using: :gin
    t.index ["election_type"], name: "index_election_surveys_on_election_type"
    t.index ["election_year"], name: "index_election_surveys_on_election_year"
    t.index ["parties"], name: "index_election_surveys_on_parties", using: :gin
    t.index ["questions"], name: "index_election_surveys_on_questions", using: :gin
    t.index ["slug"], name: "index_election_surveys_on_slug", unique: true
  end

  create_table "gift_subscriptions", force: :cascade do |t|
    t.bigint "subscription_id"
    t.bigint "plan_id"
    t.integer "duration"
    t.text "giver_given_name"
    t.text "giver_surname"
    t.text "giver_email_address"
    t.text "first_address_line_1"
    t.text "first_address_line_2"
    t.text "first_city"
    t.text "first_county"
    t.text "first_post_code"
    t.text "first_country_code"
    t.text "notes"
    t.text "redemption_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "stripe_id"
    t.datetime "charged_at", precision: nil
    t.index ["charged_at"], name: "index_gift_subscriptions_on_charged_at"
    t.index ["plan_id"], name: "index_gift_subscriptions_on_plan_id"
    t.index ["redemption_code"], name: "index_gift_subscriptions_on_redemption_code", unique: true
    t.index ["stripe_id"], name: "index_gift_subscriptions_on_stripe_id", unique: true
    t.index ["subscription_id"], name: "index_gift_subscriptions_on_subscription_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.text "stripe_id"
    t.text "number"
    t.text "receipt_number"
    t.integer "total"
    t.boolean "closed"
    t.boolean "paid"
    t.boolean "attempted"
    t.boolean "forgiven"
    t.date "created_on"
    t.date "due_on"
    t.datetime "period_starts_at", precision: nil
    t.datetime "period_ends_at", precision: nil
    t.datetime "next_payment_attempt_at", precision: nil
    t.jsonb "lines", default: {}
    t.bigint "user_id"
    t.bigint "subscription_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["created_on"], name: "index_invoices_on_created_on"
    t.index ["due_on"], name: "index_invoices_on_due_on"
    t.index ["number"], name: "index_invoices_on_number"
    t.index ["receipt_number"], name: "index_invoices_on_receipt_number"
    t.index ["stripe_id"], name: "index_invoices_on_stripe_id", unique: true
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.date "issue_date"
    t.boolean "published", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["issue_date"], name: "index_issues_on_issue_date", unique: true
    t.index ["published"], name: "index_issues_on_published"
  end

  create_table "landing_pages", force: :cascade do |t|
    t.text "name"
    t.text "slug", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "template"
    t.index ["slug"], name: "index_landing_pages_on_slug", unique: true
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.text "mailchimp_id"
    t.text "email_address"
    t.text "given_name"
    t.text "surname"
    t.text "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_newsletter_subscribers_on_email_address"
    t.index ["mailchimp_id"], name: "index_newsletter_subscribers_on_mailchimp_id", unique: true
    t.index ["status"], name: "index_newsletter_subscribers_on_status"
  end

  create_table "plans", force: :cascade do |t|
    t.text "stripe_id"
    t.integer "amount"
    t.text "interval"
    t.integer "interval_count"
    t.bigint "product_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_id"], name: "index_plans_on_product_id"
    t.index ["stripe_id"], name: "index_plans_on_stripe_id", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.text "name"
    t.text "stripe_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "base_price", default: 0
    t.index ["stripe_id"], name: "index_products_on_stripe_id", unique: true
  end

  create_table "subscriptions", force: :cascade do |t|
    t.text "stripe_id"
    t.bigint "plan_id"
    t.bigint "user_id"
    t.datetime "current_period_ends_at", precision: nil
    t.text "status"
    t.jsonb "metadata"
    t.datetime "canceled_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "subscription_type", default: "stripe"
    t.boolean "cancel_at_period_end"
    t.bigint "product_id"
    t.datetime "trial_ends_at", precision: nil
    t.text "landing_page_slug"
    t.index ["current_period_ends_at"], name: "index_subscriptions_on_current_period_ends_at"
    t.index ["landing_page_slug"], name: "index_subscriptions_on_landing_page_slug"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["product_id"], name: "index_subscriptions_on_product_id"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["stripe_id"], name: "index_subscriptions_on_stripe_id", unique: true
    t.index ["subscription_type"], name: "index_subscriptions_on_subscription_type"
    t.index ["trial_ends_at"], name: "index_subscriptions_on_trial_ends_at"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.text "name"
    t.text "slug"
    t.boolean "displayable", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "autolink", default: false
    t.index "to_tsvector('english'::regconfig, name)", name: "tags_name", using: :gin
    t.index ["autolink"], name: "index_tags_on_autolink"
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "user_notes", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_user_notes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "email_address", null: false
    t.text "crypted_password"
    t.text "salt"
    t.text "given_name"
    t.text "surname"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "remember_me_token"
    t.datetime "remember_me_token_expires_at", precision: nil
    t.text "reset_password_token"
    t.datetime "reset_password_token_expires_at", precision: nil
    t.datetime "reset_password_email_sent_at", precision: nil
    t.integer "access_count_to_reset_password_page", default: 0
    t.text "nickname"
    t.text "portrait"
    t.text "stripe_id"
    t.datetime "set_password_at", precision: nil
    t.boolean "subscribed_weekly", default: false
    t.string "role", default: "user"
    t.text "address_line_1"
    t.text "address_line_2"
    t.text "city"
    t.text "county"
    t.text "post_code"
    t.text "country"
    t.text "country_code"
    t.jsonb "metadata"
    t.text "hub"
    t.datetime "banned_at", precision: nil
    t.text "full_name"
    t.integer "sources_count", default: 0
    t.text "card_last_4"
    t.text "card_brand"
    t.datetime "deleted_at", precision: nil
    t.jsonb "notes", default: {}
    t.datetime "payment_failed_email_sent_at", precision: nil
    t.text "rss_key"
    t.index "to_tsvector('english'::regconfig, address_line_1)", name: "users_address_line_1", using: :gin
    t.index "to_tsvector('english'::regconfig, address_line_2)", name: "users_address_line_2", using: :gin
    t.index "to_tsvector('english'::regconfig, full_name)", name: "users_full_name", using: :gin
    t.index "to_tsvector('english'::regconfig, given_name)", name: "users_given_name", using: :gin
    t.index "to_tsvector('english'::regconfig, surname)", name: "users_surname", using: :gin
    t.index ["banned_at"], name: "index_users_on_banned_at"
    t.index ["city"], name: "index_users_on_city"
    t.index ["country_code"], name: "index_users_on_country_code"
    t.index ["county"], name: "index_users_on_county"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["hub"], name: "index_users_on_hub"
    t.index ["nickname"], name: "index_users_on_nickname"
    t.index ["notes"], name: "index_users_on_notes", using: :gin
    t.index ["post_code"], name: "index_users_on_post_code"
    t.index ["remember_me_token"], name: "index_users_on_remember_me_token"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["role"], name: "index_users_on_role"
    t.index ["sources_count"], name: "index_users_on_sources_count"
    t.index ["stripe_id"], name: "index_users_on_stripe_id", unique: true
  end

  create_table "visitors", force: :cascade do |t|
    t.json "viewed_articles", default: {}
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_visitors_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "artworks", column: "featured_artwork_id"
  add_foreign_key "articles", "issues"
  add_foreign_key "artworks", "articles"
  add_foreign_key "comments", "articles"
  add_foreign_key "comments", "users"
  add_foreign_key "gift_subscriptions", "subscriptions"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "invoices", "users"
  add_foreign_key "plans", "products"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "user_notes", "users"
  add_foreign_key "visitors", "users"
end
