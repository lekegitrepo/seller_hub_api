class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]

  respond_to :json

  def index
    # respond_with Product.all
    products = Product.search(params).page(params[:page]).per(params[:per_page])
    render json: products, meta: pagination(products, params[:per_page]), adapter: :json
  end

  def show
    respond_with Product.find(params[:id])
  end

  def create
    product = current_user.products.build(product_params)
    if product.save
      render json: product, status: 201, location: [:api_v1, product]
    else
      render json: { errors: product.errors }, status: 422
    end
  end

  def update
    product = current_user.products.find(params[:id])
    if product.update(product_params)
      render json: product, status: 200, location: [:api_v1, product]
    else
      render json: { errors: product.errors }, status: 422
    end
  end

  def destroy
    product = current_user.products.find(params[:id])
    product.destroy
    head 204
  end

  private

  def product_params
    params.require(:product).permit(:title, :price, :published)
  end

  def pagination(paginated_array, per_page)
    { pagination: { per_page: per_page.to_i,
                    total_pages: paginated_array.total_pages,
                    total_objects: paginated_array.total_count } }
  end
end
