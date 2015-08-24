class CreateTestFiles < ActiveRecord::Migration
  def up
    create_table :test_files do |t|
      t.text :path
      t.bigint :total_failures
      t.integer :first_build
      t.timestamp :last_failure
      t.timestamp :first_failure
    end
    add_index :test_files, :path
    add_index :test_files, :first_build
  end
  def down
    drop_table :test_files
  end
end
