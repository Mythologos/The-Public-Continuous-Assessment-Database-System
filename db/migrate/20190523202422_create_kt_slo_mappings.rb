class CreateKtSloMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :kt_slo_mappings, id: false do |t|
      t.integer :kt_id, limit: 2, null: false
      t.integer :slo_id, limit: 2, null: false

      t.timestamps
    end
  end
end
