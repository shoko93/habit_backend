class CreatePostBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :post_bookmarks do |t|
      t.text :line_id
      t.integer :post_id
      t.timestamps
    end
    add_foreign_key :post_bookmarks, :posts
  end
end
