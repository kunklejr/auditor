require 'rails/generators'
require 'rails/generators/migration'

module Auditor
  module Generators
    class UpgradeGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc "Create upgrade migration for Auditor audits table"

      source_root File.expand_path("../templates", __FILE__)

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end

      def create_migration_file
        migration_template 'upgrade.rb', 'db/migrate/upgrade_audits_table.rb'
      end
    end
  end
end
