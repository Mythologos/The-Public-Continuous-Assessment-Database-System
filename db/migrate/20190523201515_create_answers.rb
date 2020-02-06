class CreateAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :answers, id: false do |t|
      t.string :answer_given, default: 'Unanswered'
      t.integer :crn, limit: 3, null: false
      t.boolean :correct?, null: false
      t.integer :question_id, null: false
      t.integer :section_number, limit: 2, null: false
      t.integer :student_id, null: false
      t.integer :year_offered, limit: 2, null: false

      t.timestamps
    end
  end
end
