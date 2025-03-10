class Api::V1::RolesController < Api::V1::BaseController
  before_action :set_role, only: [:show, :destroy, :update]

  def index
    per_page = params[:per_page] || 5
    page = params[:page] || 1
    @roles = Role.page(page).per(per_page)
    if @roles.present?
      render json: { status: 200, message: "Roles fetched successefully", current_page: @roles.current_page, total_page: @roles.total_pages, total_count: @roles.total_count, data: ActiveModelSerializers::SerializableResource.new(@roles, each_serializer: RoleSerializer)}, status: :ok
    else
      render json: { status: 200, message: "No roles found", data: [] }, status: :ok
    end
  end

  def show
    render json: { status: 200, message: "role fetched successefully", data: RoleSerializer.new(@role)}
  end

  def create
    begin
      role = Role.new(roles_params)
      if role.save
        render json: {
        status: 201,
        message: "Role created successfully",
        data: RoleSerializer.new(role)
      }, status: :created
      else
        render json: {message: role.errors.full_messages, status: 422 }, status: :unprocessable_entity
      end
    rescue
      render json: { message: "Something went wrong", status: 500 }, status: :internal_server_error
    end
  end

  def update
    begin
      if @role.update(roles_params)
        render json: { status: 200, message: "Role updated successefully", data: RoleSerializer.new(@role)}
      else
        render json: {message: @role.errors.full_messages, status: 422 }, status: :unprocessable_entity
      end
    rescue
      render json: { message: "Something went wrong", status: 500 }, status: :internal_server_error
    end
  end

  def destroy
    if @role.destroy
      render json: { status: 200, message: "Role deleted successefully"}, status: :ok
    else
      render json: { status: 422, message: @role.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { status: 500, message: "Something went wrong", error: e.message }, status: :internal_server_error
  end

  private

  def roles_params
    params.require(:roles).permit(:name)
  end

  def set_role
    begin
      @role = Role.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "Role not found" }, status: :not_found
    end
  end
end
      
