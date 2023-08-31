class PostsController < ApplicationController
    def create
        data = {id_token: post_params[:line_id_token], client_id: '2000560013'}
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
            post = Post.new(title: post_params[:title], text_body: post_params[:text_body], line_id: line_id)
            post.save
            response_success(:post, :create)
        else
            response_internal_server_error
        end

        # @user = User.new(user_params)
        # if @user.name.blank?
        #   # 必須パラメータが欠けている場合
        #   response_bad_request
        # else
        #   if User.exists?(email: @user.email)
        #     # 既に登録済みのメールアドレスで登録しようとした場合
        #     response_conflict(:user)
        #   else
        #     if @user.save
        #       # ユーザ登録成功
        #       response_success(:user, :create)
        #     else
        #       # 何らかの理由で失敗
        #       response_internal_server_error
        #     end
        #   end
        # end
    end

    def post_params
        params.require(:post).permit(:title, :text_body, :line_id_token)
    end
end
