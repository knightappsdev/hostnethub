class CreateHostingPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :hosting_plans do |t|
      t.string :name
      t.text :description
      t.decimal :price_monthly
      t.integer :websites_limit
      t.integer :storage_gb
      t.integer :bandwidth_gb
      t.boolean :email_marketing
      t.boolean :seo_tools
      t.boolean :social_scheduler
      t.boolean :migration_support
      t.boolean :featured
      t.boolean :active

      t.timestamps
    end
  end
end
