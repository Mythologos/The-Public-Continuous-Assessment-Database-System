class CreateStudents < ActiveRecord::Migration[6.0]
  def change
    create_table :students, id: false do |t|
      t.integer :act_math_score, limit: 1
      t.integer :act_score, limit: 1
      t.string :ethnicity
      t.string :gender
      t.string :math_placement_level, limit: 3
      t.integer :nh_value, null: false
      t.boolean :research_consent?, default: false
      t.integer :sat_math_score, limit: 2
      t.integer :sat_score, limit: 2
      t.integer :student_id, null: false

      t.timestamps
    end
  end
end
