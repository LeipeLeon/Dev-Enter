class CreateDependsOns < ActiveRecord::Migration
  def self.up
    create_table :depends_ons do |t|
      t.integer :dependency_id
      t.integer :version_id

      t.timestamps
    end
  end

  def self.down
    drop_table :depends_ons
  end
end
