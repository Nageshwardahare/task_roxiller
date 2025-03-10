class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    # Check if the request is a GET request and the Authorization header is blank
    if request.get? && request.headers['Authorization'].blank?
      render json: { status: 401, message: "Authorization header not found." }, status: :unauthorized
      return
    end

    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last

      begin
        if BlacklistToken.exists?(token: token)
          render json: { status: 401, message: "You need to sign in." }, status: :unauthorized
          return
        end

        jwt_payload = JWT.decode(token, Rails.application.credentials.jwt_secret_key).first
        @current_user = User.find(jwt_payload['user_id'])

      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { status: 401, message: "Invalid token." }, status: :unauthorized
      end
    end
  end
end
