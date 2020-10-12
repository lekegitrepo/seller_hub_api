class ProductSerializer < ActiveModel::Serializer
  cached

  attributes :id, :title, :price, :published
  belongs_to :user

  def cache_key
    [object, scope]
  end
end
