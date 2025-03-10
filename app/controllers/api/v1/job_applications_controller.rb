class Api::V1::JobApplicationsController < Api::V1::BaseController
  before_action :set_job_application, only: [:show, :destroy, :update]

  def index
    per_page = params[:per_page] || 5
    page = params[:page] || 1
    @job_applications = JobApplication.page(page).per(per_page)
    if @job_applications.present?
      render json: { status: 200, message: "Job applications fetched successefully", current_page: @job_applications.current_page, total_page: @job_applications.total_pages, total_count: @job_applications.total_count, data: ActiveModelSerializers::SerializableResource.new(@job_applications, each_serializer: JobApplicationsSerializer)}, status: :ok
    else
      render json: { status: 200, message: "No Job applications found", data: [] }, status: :ok
    end
  end

  def show
    render json: { status: 200, message: "Job_application fetched successefully", data: JobApplicationsSerializer.new(@job_application)}
  end

  def create
    begin
      job_application = JobApplication.new(job_applications_params)
      if job_application.save
        render json: {
        status: 201,
        message: "Job application created successfully",
        data: JobApplicationsSerializer.new(job_application)
      }, status: :created
      else
        render json: {message: job_application.errors.full_messages, status: 422 }, status: :unprocessable_entity
      end
    rescue
      render json: { message: "Something went wrong", status: 500 }, status: :internal_server_error
    end
  end

  def update
    begin
      if @job_application.update(job_applications_params)
        render json: { status: 200, message: "Job application updated successefully", data: JobApplicationsSerializer.new(@job_application)}
      else
        render json: {message: @job_application.errors.full_messages, status: 422 }, status: :unprocessable_entity
      end
    rescue
      render json: { message: "Something went wrong", status: 500 }, status: :internal_server_error
    end
  end

  def destroy
    if @job_application.destroy
      render json: { status: 200, message: "Job application deleted successefully"}, status: :ok
    else
      render json: { status: 422, message: @job_application.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { status: 500, message: "Something went wrong", error: e.message }, status: :internal_server_error
  end

  private

  def job_applications_params
    params.require(:job_applications).permit(:user_id)
  end

  def set_job_application
    begin
      @job_application = JobApplication.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { status: 404, message: "Job_application not found" }, status: :not_found
    end
  end
end
  
