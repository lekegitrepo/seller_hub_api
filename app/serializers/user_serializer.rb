class UserSerializer < ActiveModel::Serializer
  # embed :ids, include: true
  attributes :id, :email, :created_at, :updated_at, :auth_token
  has_many :products
end
