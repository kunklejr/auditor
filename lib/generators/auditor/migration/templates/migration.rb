class CreateAuditsTable < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer, :null => false
      t.column :auditable_type, :string, :null => false
      t.column :auditable_version, :integer
      t.column :user_id, :integer, :null => false
      t.column :user_type, :string, :null => false
      t.column :action, :string, :null => false
      t.column :message, :text
      t.column :edits, :text
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :audits
  end
end