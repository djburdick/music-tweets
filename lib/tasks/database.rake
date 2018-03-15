require 'cassandra'

namespace :db do
  desc "Setup cassandra"
  task :setup do
    puts "Setting up cassandra Keyspace and Tables"

    setup_keyspace_tables('music_tweets')
    setup_keyspace_tables('music_tweets_test')
  end
end

def setup_keyspace_tables(keyspace)
  cluster = Cassandra.cluster
  session  = cluster.connect('system')

  keyspace_definition = <<-KEYSPACE_CQL
    CREATE KEYSPACE #{keyspace} 
    WITH replication = {
      'class': 'SimpleStrategy',
      'replication_factor': 1
    }
  KEYSPACE_CQL

  table_definition = <<-TABLE_CQL
    CREATE TABLE events (
      id INT,
      date DATE,
      comment VARCHAR,
      PRIMARY KEY (id)
    )
  TABLE_CQL

  session.execute(keyspace_definition)
  session.execute("USE #{keyspace}")
  session.execute(table_definition)
end



