class CreateInstructions < ActiveRecord::Migration[6.0]
  def change
    create_table :instructions, id: false do |t|
      t.integer :course_id, limit: 2, null: false
      t.string :course_discipline, limit: 4, null: false
      t.integer :kt_id, limit: 2, null: false
      t.string :mapping_relationship, null: false

      t.timestamps
    end
  end
end
