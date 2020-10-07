class OrderProductSerializer < ProductSerializer # ActiveModel::Serializer
  # attributes :id
  def include_user?
    false
  end
end
