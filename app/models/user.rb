require 'jwt'

class User < ApplicationRecord
  belongs_to :role
  has_many :job_applications, dependent: :destroy
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable


  validates :password, presence: true, length: { minimum: 6 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def create_new_jwt_token
    payload = { user_id: self.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.credentials.jwt_secret_key, 'HS256')
  end

  def admin?
    role&.name == "Admin"
  end

  def candidate?
    role&.name == "Candidate"
  end
end
