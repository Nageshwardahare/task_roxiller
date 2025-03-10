class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :destroy, :update]
  skip_before_action :authenticate_user, only: [:create]
  before_action :authorize_admin, only: [:index]
  before_action :authorize_self_or_admin, only: [:show]

  def index
    per_page = params[:per_page] || 5
    page = params[:page] || 1
    @users = User.includes(:job_applications).page(page).per(per_page)

    if @users.present?
      render json: { 
        status: 200, 
        message: "Users fetched successfully", 
        current_page: @users.current_page, 
        total_page: @users.total_pages, 
        total_count: @users.total_count, 
        data: ActiveModelSerializers::SerializableResource.new(@users, each_serializer: UserSerializer)
      }, status: :ok
    else
      render json: { status: 200, message: "No users found", data: [] }, status: :ok
    end
  end

  def show
    render json: { 
      status: 200, 
      message: "User fetched successfully", 
      data: UserSerializer.new(@user)
    }
  end

  def create
    user = User.new(users_params)
    if user.save
      render json: { 
        status: 201, 
        message: "User created successfully", 
        data: UserSerializer.new(user)
      }, status: :created
    else
      render json: { message: user.errors.full_messages, status: 422 }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { message: "Something went wrong", error: e.message, status: 500 }, status: :internal_server_error
  end

  def update
    if @user.update(users_params)
      render json: { status: 200, message: "User updated successfully", data: UserSerializer.new(@user) }
    else
      render json: { message: @user.errors.full_messages, status: 422 }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { message: "Something went wrong", error: e.message, status: 500 }, status: :internal_server_error
  end

  def destroy
    if @user.destroy
      render json: { status: 200, message: "User deleted successfully" }, status: :ok
    else
      render json: { status: 422, message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { status: 500, message: "Something went wrong", error: e.message }, status: :internal_server_error
  end

  private

  def users_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role_id)
  end
    
  def set_user
    @user = User.find_by(id: params[:id])
    render json: { status: 404, message: "User not found" }, status: :not_found unless @user
  end

  def authorize_admin
    forbidden("You are not authorized.") unless @current_user&.admin?
  end

  def authorize_self_or_admin
    unless @current_user&.admin? || @current_user == @user
      forbidden("You are not authorized to view this user.")
    end
  end

  def forbidden(message)
    render json: { status: 403, message: message }, status: :forbidden
  end
end
