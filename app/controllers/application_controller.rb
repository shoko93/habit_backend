class ApplicationController < ActionController::API
    def verify_line_id_token(line_id_token)
        data = {id_token: line_id_token, client_id: ENV["LINE_CLIENT_ID"]}
        uri = URI.parse("https://api.line.me/oauth2/v2.1/verify")
        response = Net::HTTP.post_form(uri, data)
        if response.code == "200"
            response_json = JSON.parse(response.body)
        else
            response_json = nil
        end
    end

    def set_user_name(line_id, name)
        if !User.exists?(line_id: line_id)
            user = User.new(line_id: line_id, name: name)
            user.save
        end
    end

    # 200 Success
    def response_success(class_name, action_name)
        render status: 200, json: { status: 200, message: "Success #{class_name.capitalize} #{action_name.capitalize}" }
    end
    
    # 400 Bad Request
    def response_bad_request
        render status: 400, json: { status: 400, message: 'Bad Request' }
    end
    
    # 401 Unauthorized
    def response_unauthorized
        render status: 401, json: { status: 401, message: 'Unauthorized' }
    end
    
    # 404 Not Found
    def response_not_found(class_name = 'page')
        render status: 404, json: { status: 404, message: "#{class_name.capitalize} Not Found" }
    end
    
    # 409 Conflict
    def response_conflict(class_name)
        render status: 409, json: { status: 409, message: "#{class_name.capitalize} Conflict" }
    end
    
    # 500 Internal Server Error
    def response_internal_server_error
        render status: 500, json: { status: 500, message: 'Internal Server Error' }
    end
end
