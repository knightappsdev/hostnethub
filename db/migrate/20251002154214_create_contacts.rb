class CreateContacts < ActiveRecord::Migration[7.2]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :company
      t.string :job_title
      t.string :lifecycle_stage
      t.integer :contact_score
      t.text :notes
      t.references :user, null: true, foreign_key: true
      t.references :lead, null: true, foreign_key: true

      t.timestamps
    end
  end
end
