class CreateBuilds < ActiveRecord::Migration
  def up
    create_table :builds do |t|
      t.bigint :build_number
      t.text :user
      t.float :build_time
      t.timestamp :queued_at
      t.timestamp :stop_time
    end
    add_index :builds, :build_number
  end

  def down
    drop_table :builds
  end
end
