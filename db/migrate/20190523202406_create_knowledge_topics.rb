class CreateKnowledgeTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :knowledge_topics, id: false do |t|
      # Note: replaced the start end time for being "active" with the boolean.
      # We can use the timestamps to our advantage.
      t.boolean :active_topic?, null: false, default: true
      t.string :kt_area, limit: 4, null: false
      t.integer :kt_id, limit: 2, null: false
      t.string :kt_name, null: false
      t.string :kt_unit, null: false
      t.integer :year_added, limit: 2

      t.timestamps
    end
  end
end
