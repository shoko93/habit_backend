class CreatePostsTags < ActiveRecord::Migration[7.0]
  def change
    create_table :posts_tags do |t|
      t.integer :post_id
      t.integer :tag_id
      t.timestamps
    end
    add_foreign_key :posts_tags, :posts
    add_foreign_key :posts_tags, :tags
  end
end
