ActiveAdmin.register_page "Reports" do
  content do
    render partial: 'admin/reports/types'
  end

  page_action :item_waiting_uninstallation, method: :get do
    @items = Product.available_products.need_uninstallation
    render 'admin/items/waiting_for_uninstallation'
  end

  page_action :sale_waiting_delivery, method: :get do
    @sales = Sale.waiting_delivery
    render 'admin/sales/waiting_delivery'
  end
end
