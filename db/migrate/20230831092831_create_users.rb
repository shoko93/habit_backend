class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.text :line_id, null: false
      t.text :name
      t.timestamps
    end
    add_index :users, [:line_id], unique: true
  end
end
