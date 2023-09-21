class PostsController < ApplicationController
    def index
        line_id_token = params[:line_id_token]
        posts = set_like_and_bookmark(Post.order(updated_at: :DESC), line_id_token)
        if !posts.nil?
            render json: posts
        else
            response_internal_server_error
        end
    end

    def search
        line_id_token = params[:line_id_token]
        keyword = params[:keyword]
        tags = params[:tags]
        if !keyword.nil? && !keyword.empty? && !tags.nil? && !tags.empty?
            ids = Post.select(:id).includes(:tags)
                        .where("title like ? or text_body like ?", "%" + keyword + "%", "%" + keyword + "%")
                        .where("tags.tag in (?)", tags).references(:tags)
            post_ids = Array.new
            ids.map do |item|
                post_ids.push(item.id)
            end
            posts = Post.where(id: post_ids)
        elsif !keyword.nil? && !keyword.empty?
            posts = Post.where("title like ? or text_body like ?", "%" + keyword + "%", "%" + keyword + "%")
        elsif !tags.nil? && !tags.empty?
            ids = Post.select(:id).includes(:tags).where("tags.tag in (?)", tags).references(:tags)
            post_ids = Array.new
            ids.map do |item|
                post_ids.push(item.id)
            end
            posts = Post.where(id: post_ids)
        else
            posts = Post.all
        end

        posts = set_like_and_bookmark(posts, line_id_token)
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
            bookmarks = PostBookmark.select(:post_id).where(line_id:response_json["sub"])
        else
            return response_internal_server_error
        end
        post_ids = Array.new
        bookmarks.map do |item|
            post_ids.push(item.post_id)
        end
        posts = set_like_and_bookmark(Post.where(id: post_ids).order(updated_at: :DESC), line_id_token)
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
        json = post.as_json(include: [:tags, :user])
        json[:like] = !like.nil?
        json[:bookmark] = !bookmark.nil?
        render json: json
    end

    def create
        if !create_params[:line_id_token].nil?
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

        render json: post
    end

    def image
        post = Post.find(params[:id])
        post.update(image: params[:image])
        response_success(:post, :image)
    end

    def update
        response_json = verify_line_id_token(create_params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            set_user_name(line_id, response_json["name"])
        else
            return response_internal_server_error
        end
        
        post = Post.find(params[:id])
        post.update(title: update_params[:title], text_body: update_params[:text_body], line_id: line_id)
        
        update_params[:tags].each do |tag|
            if !Tag.exists?(tag: tag)
                new_tag = Tag.new(tag: tag)
                new_tag.save
            end
            if !PostsTag.exists?(tag_id: Tag.find_by(tag: tag).id, post_id: params[:id])
                post_tag = PostsTag.new(post_id: params[:id], tag_id: Tag.find_by(tag: tag).id)
                post_tag.save
            end
        end

        response_success(:post, :update)
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

    def unbookmark
        response_json = verify_line_id_token(params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            set_user_name(line_id, response_json["name"])
        else
            return response_internal_server_error
        end
        post_bookmark = PostBookmark.find_by(line_id: line_id, post_id: params[:id])
        post_bookmark.delete
        response_success(:post, :unbookmark)
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

    def unlike
        response_json = verify_line_id_token(params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            set_user_name(line_id, response_json["name"])
        else
            return response_internal_server_error
        end
        post_like = PostLike.find_by(line_id: line_id, post_id: params[:id])
        post_like.delete
        response_success(:post, :unlike)
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
        render json: post_comment
    end

    def comments
        comments = PostComment.where(post_id: params[:id]).order(:created_at)
        response_json = verify_line_id_token(params[:line_id_token])
        if !response_json.nil?
            line_id = response_json["sub"]
            likes = CommentLike.where(line_id: response_json["sub"])
            comments_result = Array.new
            comments.map do |item|
                json = item.as_json(include: [:user])
                if likes.select{|like| like.comment_id == item.id}.length > 0
                    json[:like] = true
                else
                    json[:like] = false
                end
                comments_result.push(json)
            end
        else
            return response_internal_server_error
        end
        render json: comments_result
    end 

    def delete
        Post.find(params[:id]).destroy
        PostsTag.where(post_id: params[:id]).delete_all
        response_success(:post, :delete)
    end

    def create_params
        params.require(:post).permit!
    end

    def update_params
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
                json = item.as_json(include: [:tags, :user])
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
