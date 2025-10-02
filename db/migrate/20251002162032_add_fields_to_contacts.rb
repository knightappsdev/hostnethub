class AddFieldsToContacts < ActiveRecord::Migration[7.2]
  def change
    add_column :contacts, :website, :string
    add_column :contacts, :address, :string
    add_column :contacts, :city, :string
    add_column :contacts, :state, :string
    add_column :contacts, :postal_code, :string
    add_column :contacts, :country, :string
    add_column :contacts, :source, :string
    add_column :contacts, :description, :text
  end
end
