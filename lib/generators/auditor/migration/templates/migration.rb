class CreateAuditsTable < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer, :null => false
      t.column :auditable_type, :string, :null => false
      t.column :owner_id, :integer, :null => false
      t.column :owner_type, :string, :null => false
      t.column :user_id, :integer, :null => false
      t.column :user_type, :string, :null => false
      t.column :action, :string, :null => false
      t.column :audited_changes, :text
      t.column :version, :integer, :default => 0
      t.column :comment, :text
      t.column :created_at, :datetime, :null => false
    end

    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at
  end

  def self.down
    drop_table :audits
  end
end
