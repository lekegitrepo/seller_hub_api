FactoryBot.define do
  factory :user do
    email { 'test@gmail.com' }
    password { '123456789' }
    password_confirmation { '123456789' }
  end
end
