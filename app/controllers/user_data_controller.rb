class UserDataController < ApplicationController
  before_action :set_cors_headers
  after_action :allow_iframe

  SESSION_DURATION = 300 # 5 minutes in seconds
  JWT_ALGORITHM = 'HS256'

  def get_user_data
    token = params[:token] || params[:access_token]
    session_token = params[:session_token]
    chat_id = params[:chat_id]
    thread_id = params[:thread_id]
    entity_id = params[:entity_id]

    respond_to do |format|
      format.html do
        render :get_user_data
      end

      format.json do
        unless chat_id && thread_id && entity_id
          render json: { error: "chat_id, thread_id and entity_id are required" }, status: :bad_request
          return
        end

        # Check if valid JWT token exists
        if session_token.present? && valid_agent_jwt_token?(session_token)
          Rails.logger.info "[UserDataController] Valid JWT token found"
          session_expires_in = get_jwt_expires_in(session_token)
        else
          # No valid token, require LiveChat token
          unless token
            render json: { error: "Token or valid session_token is required" }, status: :unauthorized
            return
          end

          Rails.logger.info "[UserDataController] Request params - chat_id: #{chat_id}, thread_id: #{thread_id}, entity_id: #{entity_id}, token present: #{token.present?}"

          authorized = Livechat::ChatService.confirm_agent_status(
            chat_id: chat_id,
            thread_id: thread_id,
            entity_id: entity_id,
            token: token
          )

          unless authorized
            render json: { error: "Unauthorized" }, status: :unauthorized
            return
          end

          # Create new JWT token after successful token verification
          session_token = create_agent_jwt_token
          session_expires_in = get_jwt_expires_in(session_token)
          Rails.logger.info "[UserDataController] Created new JWT token, expires in: #{session_expires_in}s"
        end

        customer = LivechatCustomer.find_by(entity_id: entity_id)

        unless customer
          render json: { error: "Customer not found" }, status: :not_found
          return
        end

        user = customer.user

        render json: {
          user: {
            id: user.id,
            username: user.username,
            email: user.email
          },
          session_token: session_token,
          session_expires_in: session_expires_in
        }
      end
    end
  end

  def options
    head :ok
  end

  private

  def jwt_secret
    Rails.application.secret_key_base
  end

  def create_agent_jwt_token
    payload = {
      exp: Time.now.to_i + SESSION_DURATION
    }
    
    JWT.encode(payload, jwt_secret, JWT_ALGORITHM)
  end

  def valid_agent_jwt_token?(token)
    return false unless token.present?

    begin
      decoded = JWT.decode(token, jwt_secret, true, { algorithm: JWT_ALGORITHM })
      payload = decoded[0]
      
      # Check expiration
      exp = payload['exp']
      return false unless exp
      
      is_valid = exp > Time.now.to_i
      Rails.logger.debug "[UserDataController] JWT token validity: #{is_valid}, exp=#{exp}, now=#{Time.now.to_i}"
      
      is_valid
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.debug "[UserDataController] JWT token invalid: #{e.class} #{e.message}"
      false
    end
  end

  def decode_agent_jwt_token(token)
    return nil unless token.present?

    begin
      decoded = JWT.decode(token, jwt_secret, true, { algorithm: JWT_ALGORITHM })
      decoded[0]
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      Rails.logger.debug "[UserDataController] JWT token decode error: #{e.class} #{e.message}"
      nil
    end
  end

  def get_jwt_expires_in(token)
    return 0 unless token.present?

    payload = decode_agent_jwt_token(token)
    return 0 unless payload
    
    exp = payload['exp']
    return 0 unless exp
    
    remaining = exp - Time.now.to_i
    [remaining, 0].max
  end

  def set_cors_headers
    headers["Access-Control-Allow-Origin"] = "*"
    headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    headers["Access-Control-Allow-Headers"] = "Content-Type"
  end

  def allow_iframe
    response.headers.except!("X-Frame-Options")
  end
end

