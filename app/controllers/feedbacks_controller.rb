class FeedbacksController < ApplicationController
  def new
    @feedback = Feedback.new
    respond_to do |format|
      format.js
    end
  end
  
  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.user = @current_user if @current_user
    respond_to do |format|
      if @feedback.save
        format.js
      end
    end
  end
  
end
