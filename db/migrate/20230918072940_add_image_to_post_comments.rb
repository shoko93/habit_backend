class AddImageToPostComments < ActiveRecord::Migration[7.0]
  def change
    add_column :post_comments, :image, :string
  end
end
