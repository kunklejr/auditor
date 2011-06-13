require 'active_support/core_ext'
require 'active_record'
require 'generators/auditor/migration/templates/migration'
require 'fileutils'

tmpdir = File.join(File.dirname(__FILE__), '..', '..', 'tmp')
FileUtils.mkdir(tmpdir) unless File.exist?(tmpdir)
test_db = File.join(tmpdir, 'test.db')

connection_spec = {
  :adapter => 'sqlite3',
  :database => test_db
}

# Delete any existing instance of the test database
FileUtils.rm test_db, :force => true

# Create a new test database
ActiveRecord::Base.establish_connection(connection_spec)

# ActiveRecord::Base.connection.initialize_schema_migrations_table

class CreateUser < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :username, :string
    end
  end

  def self.down
    drop_table :users
  end
end

class CreateModel < ActiveRecord::Migration
  def self.up
    create_table :models, :force => true do |t|
      t.column :name, :string
      t.column :value, :string
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :models
  end
end

CreateUser.up
CreateModel.up
CreateAuditsTable.up

