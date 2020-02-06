class CreateRrkQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table(:rrk_questions, primary_key: 'question_id') do |t|
      # Note: replaced the start end time for being "active" with the boolean.
      # We can use the timestamps to our advantage.
      t.boolean :active_question?, null: false, default: true
      t.string :correct_answer, null: false
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.string :incorrect_answer_1, null: false
      t.string :incorrect_answer_2, null: true
      t.string :incorrect_answer_3, null: true
      t.string :incorrect_answer_4, null: true
      t.string :incorrect_answer_5, default: 'Unanswered'
      t.integer :rrk_quiz_version, limit: 2, null: false
      t.string :question_text, null: false
      t.integer :taxonomic_id, limit: 2, null: false

      t.timestamps
    end
  end
end
