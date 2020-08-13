namespace :db do
  task import: :environment do
    import_path = "tmp/import"
    sql_file = "PostgreSQL.sql"
    database_config = Rails.configuration.database_configuration[Rails.env]

    # Import
    system "psql --no-owner --no-password #{database_config['database']} < #{import_path}/#{sql_file}"
  end
end