require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do # RSpec.describe Api::V1::UsersController, type: :controller do
  before(:each) { request.headers['Accept'] = 'application/sellerhub.v1' }

  describe 'GET #show' do
    before(:each) do
      @user = FactoryBot.create :user
      get :show, params: { id: @user.id, format: :json }
    end

    it 'returns the information about a reporter on a hash' do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe 'POST #create user' do
    context 'When user is successfully created' do
      before(:each) do
        @user_attr = FactoryBot.attributes_for :user
        post :create, { user: @user_attr, format: :json }
      end

      it 'returns the json representation of the created user record' do
        user_resp = JSON.parse(response.body, symbolize_names: true)
        expect(user_resp[:email]).to eql @user_attr[:email]
      end

      it { should respond_with 201 }
    end
  end
end
