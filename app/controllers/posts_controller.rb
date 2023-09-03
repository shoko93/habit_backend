class PostsController < ApplicationController
    def index
        render json: Post.all
    end

    def create
        if !post_params[:line_id_token].nil?
            data = {id_token: post_params[:line_id_token], client_id: ENV["LINE_CLIENT_ID"]}
            uri = URI.parse("https://api.line.me/oauth2/v2.1/verify")
            response = Net::HTTP.post_form(uri, data)
            puts JSON.parse(response.body)
            puts response.code
            if response.code == "200"
                response_json = JSON.parse(response.body)
                line_id = response_json["sub"]
                if !User.exists?(line_id: line_id)
                    user = User.new(line_id: line_id, name: response_json["name"])
                    user.save
                end
            else
                response_internal_server_error
            end
        else
            line_id = nil
        end

        post = Post.new(title: post_params[:title], text_body: post_params[:text_body], line_id: line_id)
        post.save
        response_success(:post, :create)
    end

    def post_params
        params.require(:post).permit(:title, :text_body, :line_id_token)
    end
end
