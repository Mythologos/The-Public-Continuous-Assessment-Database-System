class CreateEnrollments < ActiveRecord::Migration[6.0]
  def change
    create_table :enrollments, id: false do |t|
      t.integer :crn, limit: 3, null: false
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.string :relevant_major_participation, default: 'None', null: false
      t.float :rrk_quiz_score, scale: 2
      t.integer :rrk_quiz_version, limit: 2
      t.integer :section_number, limit: 2, null: false
      t.string :student_course_grade, limit: 2, default: 'NG', null: false
      t.integer :student_id, null: false
      t.integer :year_offered, limit: 2, null: false

      t.timestamps
    end
  end
end
