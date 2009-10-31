class AddPackageTypeToAppDependsOn < ActiveRecord::Migration
  def self.up
    add_column :app_depends_ons, :package_type, :string
  end

  def self.down
    remove_column :app_depends_ons, :package_type
  end
end
