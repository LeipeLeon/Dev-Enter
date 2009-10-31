class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.integer :dependency_id
      t.string :version
      t.integer :version_mayor
      t.integer :version_minor
      t.integer :version_bug
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :versions
  end
end
