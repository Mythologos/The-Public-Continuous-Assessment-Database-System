class CreateTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :taxonomies, id: false do |t|
      t.string :taxonomic_description
      t.integer :taxonomic_id, limit: 2, null: false
      t.string :taxonomic_name

      t.timestamps
    end
  end
end
