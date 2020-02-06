class CreateStudentLearningOutcomes < ActiveRecord::Migration[6.0]
  def change
    create_table :student_learning_outcomes, id: false do |t|
      t.string :accreditation_body
      t.boolean :active_outcome?, null: false, default: true
      t.string :slo_description, default: 'No description provided.'
      t.integer :slo_id, limit: 2, null: false
      t.string :slo_name, null: false
      t.integer :year_added, limit: 2, null: false

      t.timestamps
    end
  end
end
