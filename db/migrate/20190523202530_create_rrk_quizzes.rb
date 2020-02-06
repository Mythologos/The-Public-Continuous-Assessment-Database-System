class CreateRrkQuizzes < ActiveRecord::Migration[6.0]
  def change
    create_table :rrk_quizzes, id: false do |t|
      # Note: replaced the start end time for being "active" with the boolean.
      # We can use the timestamps to our advantage.
      t.boolean :active_quiz?, null: false, default: true
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.integer :rrk_quiz_version, limit: 2, null: false
      t.string :quiz_creator
      t.integer :total_number_of_questions, limit: 1, null: false

      t.timestamps
    end
  end
end
