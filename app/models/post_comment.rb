class PostComment < ApplicationRecord
    mount_uploader :image, ImageUploader
    has_one :user, foreign_key: :line_id, primary_key: :line_id
    has_many :comment_likes, foreign_key: :comment_id, dependent: :destroy
end
