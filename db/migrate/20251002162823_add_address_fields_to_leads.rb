class AddAddressFieldsToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :street_address, :text
    add_column :leads, :city, :string
    add_column :leads, :state, :string
    add_column :leads, :postal_code, :string
    add_column :leads, :country, :string
  end
end
