class CreatePostLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :post_likes do |t|
      t.text :line_id
      t.integer :post_id
      t.timestamps
    end
    add_foreign_key :post_likes, :posts
  end
end
