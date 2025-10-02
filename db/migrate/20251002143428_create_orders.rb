class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :customer_email
      t.string :product_name
      t.decimal :amount
      t.string :currency, default: "usd"
      t.string :status, default: "pending"
      t.string :stripe_payment_intent_id

      t.timestamps
    end
  end
end
