class AddProductIdToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :product_id, :string
  end
end
