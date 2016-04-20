class AddCountToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :count, :integer, default: 0, null: false
  end
end
