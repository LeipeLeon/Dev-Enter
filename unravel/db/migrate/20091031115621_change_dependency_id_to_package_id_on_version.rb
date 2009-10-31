class ChangeDependencyIdToPackageIdOnVersion < ActiveRecord::Migration
  def self.up
    rename_column :versions,   :dependency_id, :package_id
    rename_column :depends_ons, :dependency_id, :package_id
  end

  def self.down
    rename_column :versions,   :package_id, :dependency_id
    rename_column :depends_ons, :package_id, :dependency_id
  end
end
