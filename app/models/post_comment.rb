class PostComment < ApplicationRecord
    has_one :user, foreign_key: :line_id, primary_key: :line_id
end
