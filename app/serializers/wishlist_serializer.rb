class WishlistSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at
end
