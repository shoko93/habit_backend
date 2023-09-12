class UsersController < ApplicationController
    def get
        line_id_token = params[:line_id_token]
        response_json = verify_line_id_token(line_id_token)
        if !response_json.nil?
            user = User.find_by(line_id: response_json["sub"])
            if user.nil?
                render json: {user: nil}
            else
                render json: {user: user}
            end
        else
            return response_internal_server_error
        end
    end

    def update
        line_id_token = update_params[:line_id_token]
        response_json = verify_line_id_token(line_id_token)
        if !response_json.nil?
            user = User.find_by(line_id: response_json["sub"])
            if user.nil?
                user = User.new(line_id: response_json["sub"], name: update_params[:name])
                user.save
            else
                user.update(name: update_params[:name])
            end
            response_success(:user, :update)
        else
            return response_internal_server_error
        end
    end

    def update_params
        params.require(:user).permit(:name, :line_id_token)
    end
end
