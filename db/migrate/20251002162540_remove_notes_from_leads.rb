class RemoveNotesFromLeads < ActiveRecord::Migration[7.2]
  def change
    remove_column :leads, :notes, :text
  end
end
