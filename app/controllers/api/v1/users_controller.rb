class Api::V1::UsersController < ApplicationController
  respond_to :json

  # api/v1/users#show
  def show
    respond_with User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
