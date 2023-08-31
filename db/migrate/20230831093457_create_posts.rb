class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.text :line_id
      t.text :title
      t.text :text_body
      t.timestamps
    end
    add_foreign_key :posts, :users, column: :line_id, primary_key: :line_id
  end
end
