class CreateDeals < ActiveRecord::Migration[7.2]
  def change
    create_table :deals do |t|
      t.string :name
      t.text :description
      t.decimal :amount
      t.string :stage
      t.integer :probability
      t.date :expected_close_date
      t.date :actual_close_date
      t.references :contact, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
