RSpec.configure do |config|
  config.before(:suite) do
    #DatabaseCleaner.clean_with(:deletion)
    dump_file=Rails.root.join("spec/support/postgres.dmp")
    cmd="pg_restore -c -j 5 -v -h localhost -p 5432 -U #{ENV['AACT_DB_SUPER_USERNAME']} -d aact_test #{dump_file}"
    require 'open3'
    stdout, stderr, status = Open3.capture3(cmd)

    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
    con=ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      database: 'aact_test',
      encoding: 'utf8',
      username: 'wiki',
    ).connection
    con.execute('grant usage on schema ctgov to wiki;')
    con.execute('grant usage on schema lookup to wiki;')
    con.execute('grant usage on schema pubmed to wiki;')
    con.execute('grant select on all tables in schema ctgov to wiki;')
    con.execute('grant select on all tables in schema lookup to wiki;')
    con.execute('grant select on all tables in schema pubmed to wiki;')
    con.execute('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA lookup TO wiki');
    con.execute('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA pubmed TO wiki');
    con.execute('grant all on all tables in schema lookup to wiki;')
    con.execute('grant all on all tables in schema pubmed to wiki;')
    con.disconnect!
    con = nil
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :deletion
  end

end
