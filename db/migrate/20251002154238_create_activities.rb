class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.string :activity_type
      t.string :title
      t.text :description
      t.datetime :activity_date
      t.references :contact, null: true, foreign_key: true
      t.references :lead, null: true, foreign_key: true
      t.references :deal, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
