class CreateCommentLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :comment_likes do |t|
      t.text :line_id
      t.integer :comment_id
      t.timestamps
    end
    add_foreign_key :comment_likes, :post_comments, column: :comment_id
  end
end
