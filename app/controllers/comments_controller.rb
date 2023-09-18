class CommentsController < ApplicationController
    def image
        comment = PostComment.find(params[:id])
        comment.update(image: params[:image])
        response_success(:comment, :image)
    end

    def update
        comment = PostComment.find(params[:id])
        comment.update(comment: update_params[:comment])
        response_success(:comment, :update)
    end

    def delete
        PostComment.find(params[:id]).destroy
        response_success(:comment, :delete)
    end

    def like
        if !like_params[:line_id_token].nil?
            response_json = verify_line_id_token(like_params[:line_id_token])
            if !response_json.nil?
                line_id = response_json["sub"]
                set_user_name(line_id, response_json["name"])
            else
                return response_internal_server_error
            end
        else
            line_id = nil
        end

        if !CommentLike.exists?(line_id: line_id, comment_id: like_params[:comment_id])
            comment_like = CommentLike.new(comment_id: like_params[:comment_id], line_id: line_id)
            comment_like.save
        end
        response_success(:comment, :like)
    end

    def unlike
        response_json = verify_line_id_token(params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            set_user_name(line_id, response_json["name"])
        else
            return response_internal_server_error
        end
        comment_like = CommentLike.find_by(line_id: line_id, comment_id: params[:id])
        comment_like.delete
        response_success(:comment, :unlike)
    end

    def update_params
        params.require(:comment).permit(:comment)
    end

    def like_params
        params.require(:like).permit(:comment_id, :line_id_token)
    end
end
