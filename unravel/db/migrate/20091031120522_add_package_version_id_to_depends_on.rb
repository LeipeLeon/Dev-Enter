class AddPackageVersionIdToDependsOn < ActiveRecord::Migration
  def self.up
    add_column :depends_ons, :package_version_id, :integer
  end

  def self.down
    remove_column :depends_ons, :package_version_id
  end
end
