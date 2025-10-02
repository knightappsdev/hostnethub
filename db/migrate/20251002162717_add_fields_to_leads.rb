class AddFieldsToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :job_title, :string
    add_column :leads, :industry, :string
    add_column :leads, :annual_revenue, :decimal
    add_column :leads, :number_of_employees, :integer
  end
end
