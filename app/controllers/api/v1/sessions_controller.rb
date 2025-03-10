class Api::V1::SessionsController < ApplicationController
	skip_before_action :verify_authenticity_token

  def create
    user = User.find_for_database_authentication(email: params[:user][:email])
    if user&.valid_password?(params[:user][:password])
      token = user.create_new_jwt_token
      response.set_header('Authorization', "Bearer #{token}")

      render json: {
        status: 201,
        message: "Login successfully",
        data: UserSerializer.new(user)
      }, status: :created
    else
      render json: {message: 'Invalid email or password', status: 422 }, status: :unprocessable_entity
    end
  end

  def destroy
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last

      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.jwt_secret_key).first
        user_id = jwt_payload['user_id']

        BlacklistToken.create(token: token) if User.find_by(id: user_id)
        render json: { status: 200, message: 'Logged out successfully' }, status: :ok
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { status: 401, message: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { status: 400, message: "Couldn't find an active session." }, status: :bad_request
    end
  end
end
