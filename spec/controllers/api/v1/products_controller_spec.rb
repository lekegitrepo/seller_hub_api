require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe 'GET #show' do
    before(:each) do
      @product = FactoryBot.create :product
      get :show, params: { id: @product.id }
    end

    it 'returns the information about a reporter on a hash' do
      product_response = json_response
      expect(product_response[:title]).to eql @product.title
    end

    it 'has the user object embedded' do
      product_response = json_response
      expect(product_response[:user][:email]).to eql @product.user.email
    end

    it { should respond_with 200 }
  end

  describe 'GET #index' do
    before(:each) do
      4.times { FactoryBot.create :product }
      get :index
    end

    it 'returns 4 records from the database' do
      products_response = json_response
      expect(products_response[:products].length).to eql 4
    end

    it 'returns the user object into each product' do
      products_response = json_response[:products]
      products_response.each do |product_response|
        expect(product_response[:user]).to be_present
      end
    end

    it { should respond_with 200 }

    context 'when product_ids parameter is sent' do
      before(:each) do
        @user = FactoryBot.create :user
        3.times { FactoryBot.create :product, user: @user }
        get :index, params: { product_ids: @user.product_ids }
      end

      it 'returns just the products that belong to the user' do
        products_response = json_response[:products]
        products_response.each do |product_response|
          expect(product_response[:user][:email]).to eql @user.email
        end
      end
    end

    # we added this lines for the pagination
    it { expect(json_response).to have_key(:meta) }
    it { expect(json_response[:meta]).to have_key(:pagination) }
    it { expect(json_response[:meta][:pagination]).to have_key(:per_page) }
    it { expect(json_response[:meta][:pagination]).to have_key(:total_pages) }
    it { expect(json_response[:meta][:pagination]).to have_key(:total_objects) }

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    context 'when product is successfully created' do
      before(:each) do
        user = FactoryBot.create :user
        @product_attributes = FactoryBot.attributes_for :product
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @product_attributes }
      end

      it 'renders the json representation for the created product record' do
        product_response = json_response
        expect(product_response[:title]).to eql @product_attributes[:title]
      end

      it { should respond_with 201 }
    end

    context 'when product is not created' do
      before(:each) do
        user = FactoryBot.create :user
        @invalid_product_attributes = { title: 'Smart TV', price: 'Twelve dollars' }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @invalid_product_attributes }
      end

      it 'renders an errors json' do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it 'renders the json errors on when the user could not be created' do
        product_response = json_response
        expect(product_response[:errors][:price]).to include 'is not a number'
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    before(:each) do
      @user = FactoryBot.create :user
      @product = FactoryBot.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context 'when is successfully updated' do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                                 product: { title: 'An expensive TV' } }
      end

      it 'renders the json representation for the updated user' do
        product_response = json_response
        expect(product_response[:title]).to eql 'An expensive TV'
      end

      it { should respond_with 200 }
    end

    context 'when is not updated' do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                                 product: { price: 'two hundred' } }
      end

      it 'renders an errors json' do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it 'renders the json errors on whye the user could not be created' do
        product_response = json_response
        expect(product_response[:errors][:price]).to include 'is not a number'
      end

      it { should respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryBot.create :user
      @product = FactoryBot.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { should respond_with 204 }
  end
end
