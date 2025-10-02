class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.string :priority
      t.string :status
      t.references :contact, null: true, foreign_key: true
      t.references :lead, null: true, foreign_key: true
      t.references :deal, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
