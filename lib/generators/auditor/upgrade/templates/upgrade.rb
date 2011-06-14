class UpgradeAuditsTable < ActiveRecord::Migration
  def self.up
    add_column :audits, :owner_id, :integer
    add_column :audits, :owner_type, :string

    add_index :audits, [:owner_id, :owner_type], :name => 'owner_index'
  end

  def self.down
    remove_column :audits, :owner_type
    remove_column :audits, :owner_id
  end
end
