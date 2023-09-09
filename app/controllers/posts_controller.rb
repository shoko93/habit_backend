class PostsController < ApplicationController
    def index
        line_id_token = params[:line_id_token]
        posts = set_like_and_bookmark(Post.all, line_id_token)
        if !posts.nil?
            render json: posts
        else
            response_internal_server_error
        end
    end

    def bookmarks
        line_id_token = params[:line_id_token]
        response_json = verify_line_id_token(line_id_token)
        if !response_json.nil?
            bookmarks = PostBookmark.select(:id).where(line_id:response_json["sub"])
        else
            return response_internal_server_error
        end
        post_ids = Array.new
        bookmarks.map do |item|
            post_ids.push(item.id)
        end
        posts = set_like_and_bookmark(Post.where(id: post_ids), line_id_token)
        render json: posts
    end

    def get
        line_id_token = params[:line_id_token]
        post = Post.find(params[:id])
        response_json = verify_line_id_token(line_id_token)
        if !response_json.nil?
            bookmark = PostBookmark.find_by(line_id: response_json["sub"], post_id: params[:id])
            like = PostLike.find_by(line_id: response_json["sub"], post_id: params[:id])
        else
            return response_internal_server_error
        end
        json = post.as_json(include: :tags)
        json[:like] = !like.nil?
        json[:bookmark] = !bookmark.nil?
        render json: json
    end

    def create
        if !create_params[:line_id_token].nil?
            puts create_params[:line_id_token]
            response_json = verify_line_id_token(create_params[:line_id_token])
            if !response_json.nil?
                line_id = response_json["sub"]
                set_user_name(line_id, response_json["name"])
            else
                return response_internal_server_error
            end
        else
            line_id = nil
        end

        post = Post.new(title: create_params[:title], text_body: create_params[:text_body], line_id: line_id)
        post.save

        create_params[:tags].each do |tag|
            if !Tag.exists?(tag: tag)
                new_tag = Tag.new(tag: tag)
                new_tag.save
            end
            post_tag = PostsTag.new(post_id: post.id, tag_id: Tag.find_by(tag: tag).id)
            post_tag.save
        end

        response_success(:post, :create)
    end

    def bookmark
        if !bookmark_params[:line_id_token].nil?
            response_json = verify_line_id_token(bookmark_params[:line_id_token])
            if !response_json.nil?
                line_id = response_json["sub"]
                set_user_name(line_id, response_json["name"])
            else
                return response_internal_server_error
            end
        else
            line_id = nil
        end

        if !PostBookmark.exists?(line_id: line_id, post_id: bookmark_params[:post_id])
            post_bookmark = PostBookmark.new(post_id: bookmark_params[:post_id], line_id: line_id)
            post_bookmark.save
        end
        response_success(:post, :bookmark)
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

        if !PostLike.exists?(line_id: line_id, post_id: like_params[:post_id])
            post_like = PostLike.new(post_id: like_params[:post_id], line_id: line_id)
            post_like.save
        end
        response_success(:post, :like)
    end

    def comment
        response_json = verify_line_id_token(comment_params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            set_user_name(line_id, response_json["name"])
        else
            return response_internal_server_error
        end

        post_comment = PostComment.new(post_id: comment_params[:post_id], comment: comment_params[:comment], line_id: line_id)
        post_comment.save()
    end

    def comments
        comments = PostComment.where(post_id: params[:id])
        render json: comments.as_json(include: :user)
    end 

    def create_params
        params.require(:post).permit!
    end

    def like_params
        params.require(:like).permit(:post_id, :line_id_token)
    end

    def bookmark_params
        params.require(:bookmark).permit(:post_id, :line_id_token)
    end

    def comment_params
        params.require(:comment).permit(:post_id, :comment, :line_id_token)
    end

    def get_likes_and_bookmarks(line_id_token)
        response_json = verify_line_id_token(line_id_token)
        if !response_json.nil?
            line_id = response_json["sub"]
            likes = PostLike.where(line_id: response_json["sub"])
            bookmarks = PostBookmark.where(line_id: response_json["sub"])
            return {:likes => likes, :bookmarks => bookmarks}
        else
            return nil
        end
    end

    def set_like_and_bookmark(posts, line_id_token)
        likes_and_bookmarks = get_likes_and_bookmarks(line_id_token)
        if !likes_and_bookmarks.nil?
            likes = likes_and_bookmarks[:likes]
            bookmarks = likes_and_bookmarks[:bookmarks]
            posts_result = Array.new
            posts.map do |item|
                json = item.as_json(include: :tags)
                if likes.select{|like| like.post_id == item.id}.length > 0
                    json[:like] = true
                else
                    json[:like] = false
                end
                if bookmarks.select{|bookmark| bookmark.post_id == item.id}.length > 0
                    json[:bookmark] = true
                else
                    json[:bookmark] = false
                end
                posts_result.push(json)
            end
            posts_result
        else
            return nil
        end
    end
end
