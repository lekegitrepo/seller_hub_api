class ApplicationController < ActionController::Base
  include Authenticate
  protect_from_forgery with: :null_session
end
