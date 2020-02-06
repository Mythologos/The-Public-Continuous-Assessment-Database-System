class CreateCourses < ActiveRecord::Migration[6.0]
  def change
    create_table :courses, id: false do |t|
      t.integer :auxiliary_course_id, limit: 2
      t.string :auxiliary_course_discipline, limit: 4
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.string :course_title, null: false
      t.integer :prerequisite_id_1, limit: 2
      t.string :prerequisite_discipline_1, limit: 4
      t.integer :prerequisite_id_2, limit: 2
      t.string :prerequisite_discipline_2, limit: 4

      t.timestamps
    end
  end
end
