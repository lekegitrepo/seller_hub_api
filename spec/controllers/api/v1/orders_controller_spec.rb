require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  describe 'GET #index' do
    before(:each) do
      current_user = FactoryBot.create :user
      api_authorization_header current_user.auth_token
      4.times { FactoryBot.create :order, user: current_user }
      get :index, params: { user_id: current_user.id }
    end

    it 'returns 4 order records from the user' do
      orders_response = json_response[:orders]
      expect(orders_response.length).to eql 4
    end

    # These lines are the ones added to test the pagination
    it { expect(json_response).to have_key(:meta) }
    it { expect(json_response[:meta]).to have_key(:pagination) }
    it { expect(json_response[:meta][:pagination]).to have_key(:per_page) }
    it { expect(json_response[:meta][:pagination]).to have_key(:total_pages) }
    it { expect(json_response[:meta][:pagination]).to have_key(:total_objects) }

    it { should respond_with 200 }
  end

  describe 'GET #show' do
    before(:each) do
      current_user = FactoryBot.create :user
      api_authorization_header current_user.auth_token

      @product = FactoryBot.create :product
      @order = FactoryBot.create :order, user: current_user, product_ids: [@product.id]
      get :show, params: { user_id: current_user.id, id: @order.id }
    end

    it 'returns the user order record matching the id' do
      order_response = json_response
      expect(order_response[:id]).to eql @order.id
    end

    it { should respond_with 200 }

    it 'includes the total for the order' do
      order_total = json_response
      expect(order_total[:total]).to eql @order.total.to_s
    end

    it 'includes the products on the order' do
      order_response = json_response
      p "order_response: #{order_response}"
      expect(order_response[:products].length).to eql 1
    end
  end

  describe 'POST #create' do
    before(:each) do
      current_user = FactoryBot.create :user
      api_authorization_header current_user.auth_token

      product_one = FactoryBot.create :product
      product_two = FactoryBot.create :product
      order_params = { product_ids_and_quantities: [[product_one.id, 2], [product_two.id, 3]] }
      post :create, params: { user_id: current_user.id, order: order_params }
    end

    it 'returns the just user order record' do
      order_response = json_response
      expect(order_response[:id]).to be_present
    end

    it { should respond_with 201 }
  end
end
