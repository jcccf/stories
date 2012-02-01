class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_user_details
  
  def get_user_details
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    end
  end
  
end