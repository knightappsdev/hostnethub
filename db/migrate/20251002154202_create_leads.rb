class CreateLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :leads do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :company
      t.string :website
      t.string :source
      t.string :status
      t.string :lifecycle_stage
      t.integer :lead_score
      t.text :notes
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
