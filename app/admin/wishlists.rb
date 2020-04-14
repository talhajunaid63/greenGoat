ActiveAdmin.register Wishlist do
  actions :all, except: [:destroy, :edit]

  permit_params :name, :description, :complete, :user_id

  filter :user, label: 'Client'
  filter :name
  filter :description
  filter :complete
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :name
    column :client do |wishlist|
      link_to wishlist.user, admin_client_path(wishlist.user)
    end
    column :description
    column :created_at do |wishlist|
      wishlist.created_at.strftime('%d/%m/%Y')
    end
    toggle_bool_column :complete
    actions
  end
end
