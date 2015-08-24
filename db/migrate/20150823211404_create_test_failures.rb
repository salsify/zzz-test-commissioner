class CreateTestFailures < ActiveRecord::Migration
  def up
    create_table :test_failures do |t|
      t.integer :test_file_id
      t.integer :build_num
      t.text :digest
      t.text :error
      t.text :test
      t.float :run_time
      t.timestamp :timestamp
    end
    add_index :test_failures, [:test_file_id, :build_num]
    add_index :test_failures, :test_file_id
    add_index :test_failures, :build_num
    add_index :test_failures, :digest
  end
  def down
    drop_table :test_failures
  end
end
