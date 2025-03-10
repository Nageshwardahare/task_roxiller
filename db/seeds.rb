# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_role = Role.create!(name: "Admin")
candidate_role = Role.create!(name: "Candidate")

admin = User.create!(name: "Admin User", email: "admin@example.com", password: "password", role: admin_role)

candidate1 = User.create!( name: "Candidate 1", email: "candidate1@example.com", password: "123456", role: candidate_role)

candidate2 = User.create!( name: "Candidate 2", email: "candidate2@example.com", password: "123456", role: candidate_role
)

JobApplication.create!(
  [
    { user: candidate1 },
    { user: candidate1 },
    { user: candidate2 },
    { user: candidate2 }
  ]
)