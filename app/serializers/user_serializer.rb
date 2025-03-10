class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :password, :role
  has_many :job_applications, serializer: JobApplicationsSerializer

  def role
    object.role&.name
  end
end
