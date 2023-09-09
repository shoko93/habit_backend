class CreatePostComments < ActiveRecord::Migration[7.0]
  def change
    create_table :post_comments do |t|
      t.integer :post_id
      t.text :comment
      t.text :line_id
      t.timestamps
    end
    add_foreign_key :post_comments, :posts
    add_foreign_key :post_comments, :users, column: :line_id, primary_key: :line_id
  end
end
