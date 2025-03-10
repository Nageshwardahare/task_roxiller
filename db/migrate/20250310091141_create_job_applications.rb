class CreateJobApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :job_applications do |t|
      t.references :user, foreign_key: true, null: false
      
      t.timestamps
    end
  end
end
