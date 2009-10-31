class CreateAppDependsOns < ActiveRecord::Migration
  def self.up
    create_table :app_depends_ons do |t|
      t.integer :app_id
      t.integer :dependency_id
      t.string  :version
      
      t.timestamps
    end
  end

  def self.down
    drop_table :app_depends_ons
  end
end
