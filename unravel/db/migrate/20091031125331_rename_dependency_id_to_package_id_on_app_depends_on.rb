class RenameDependencyIdToPackageIdOnAppDependsOn < ActiveRecord::Migration
  def self.up
    rename_column :app_depends_ons, :dependency_id, :package_id
    add_column    :app_depends_ons, :package_name,  :string
    add_column    :app_depends_ons, :parent_id,     :integer
  end

  def self.down
    remove_column :app_depends_ons, :parent_id
    remove_column :app_depends_ons, :package_name
    rename_column :app_depends_ons, :package_id, :dependency_id
  end
end
