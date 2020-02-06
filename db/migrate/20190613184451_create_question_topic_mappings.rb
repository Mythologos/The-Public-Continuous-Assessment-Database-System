class CreateQuestionTopicMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :question_topic_mappings, id: false do |t|
      t.integer :question_id, null: false
      t.integer :kt_id, limit: 2, null: false

      t.timestamps
    end
  end
end
