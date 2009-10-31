class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.integer :user_id
      t.string :app_name
      t.string :api_key

      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
end
