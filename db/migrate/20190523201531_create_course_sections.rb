class CreateCourseSections < ActiveRecord::Migration[6.0]
  def change
    create_table :course_sections, id: false do |t|
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.integer :crn, limit: 3, null: false
      t.string :faculty_name
      t.string :pedagogy_type, default: 'Active Learning'
      t.integer :rrk_quiz_version, limit: 2
      t.integer :section_number, limit: 2, null: false
      t.integer :semester_offered, limit: 1, null: false
      t.integer :year_offered, limit: 2, null: false

      t.timestamps
    end
  end
end
