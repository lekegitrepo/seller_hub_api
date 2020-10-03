require 'rails_helper'
require 'support/request_helpers'

RSpec.describe Api::V1::UsersController, type: :controller do # RSpec.describe Api::V1::UsersController, type: :controller do
  include Request::JsonHelpers
  before(:each) do
    request.headers['Accept'] = "application/sellerhub.v1, #{Mime[:json]}"
    request.headers['Content-Type'] = Mime[:json].to_s
  end
  describe 'GET #show' do
    before(:each) do
      @user = FactoryBot.create :user
      get :show, params: { id: @user.id, format: :json }
    end

    it 'returns the information about a reporter on a hash' do
      user_response = json_response
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe 'POST #create user' do
    context 'When user is successfully created' do
      before(:each) do
        @user_attr = FactoryBot.attributes_for :user
        post :create, params: { user: @user_attr, format: :json }
      end

      it 'returns the json representation of the created user record' do
        user_resp = json_response
        expect(user_resp[:email]).to eql @user_attr[:email]
      end

      it { should respond_with 201 }
    end

    context 'when user record is not created' do
      before(:each) do
        @invalid_user_attributes = { password: '12345678',
                                     password_confirmation: '12345678' }
        post :create, params: { user: @invalid_user_attributes, format: :json }
      end

      it 'renders an errors json' do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it 'renders the json errors on why the user could not be created' do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    context 'when user record is successfully updated' do
      before(:each) do
        @user = FactoryBot.create :user
        patch :update, params: { id: @user.id,
                                 user: { email: 'newmail@example.com' }, format: :json }
      end

      it 'renders the json representation for the updated user' do
        user_response = json_response
        expect(user_response[:email]).to eql 'newmail@example.com'
      end

      it { should respond_with 200 }
    end

    context 'when user record is not updated' do
      before(:each) do
        @user = FactoryBot.create :user
        patch :update, params: { id: @user.id,
                                 user: { email: 'bademail.com' }, format: :json }
      end

      it 'renders an errors json' do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it 'renders the json errors on when the user could not be updated' do
        user_response = json_response
        expect(user_response[:errors][:email]).to include 'is invalid'
      end

      it { should respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create :user
      delete :destroy, params: { id: @user.id, format: :json }
    end

    it { should respond_with 204 }
  end
end
