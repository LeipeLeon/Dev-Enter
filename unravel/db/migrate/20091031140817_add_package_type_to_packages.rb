class AddPackageTypeToPackages < ActiveRecord::Migration
  def self.up
    add_column :packages, :package_type, :string
    add_column :packages, :summary, :string
    rename_column :packages, :url, :homepage
    add_column :packages, :lib, :string
    add_column :packages, :description, :text
    add_column :packages, :platform, :string
    add_column :packages, :column_name, :string
  end

  def self.down
    remove_column :packages, :column_name
    remove_column :packages, :platform
    remove_column :packages, :description
    remove_column :packages, :lib
    rename_column :packages, :homepage, :url
    remove_column :packages, :summary
    remove_column :packages, :package_type
  end
end
