class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json

  def index
    # respond_with current_user.orders
    orders = current_user.orders.page(params[:page]).per(params[:per_page])
    render json: orders, meta: pagination(products, params[:per_page]), adapter: :json
  end

  def show
    respond_with current_user.orders.find(params[:id])
  end

  def create
    # order = current_user.orders.build(order_params)
    order = current_user.orders.build
    order.build_placements_with_product_ids_and_quantities(params[:order][:product_ids_and_quantities])

    if order.save
      order.reload # we reload the object so the response displays the product objects
      OrderMailer.send_confirmation(order).deliver
      render json: order, status: 201, location: [:api_v1, current_user, order]
    else
      render json: { errors: order.errors }, status: 422
    end
  end

  private

  def order_params
    params.require(:order).permit(product_ids: [])
  end

  def pagination(paginated_array, per_page)
    { pagination: { per_page: per_page.to_i,
                    total_pages: paginated_array.total_pages,
                    total_objects: paginated_array.total_count } }
  end
end
