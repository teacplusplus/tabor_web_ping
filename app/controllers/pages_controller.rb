class PagesController < ApplicationController
  def index
    @status = Status.order("created_at DESC").first
    respond_to do |format|
      format.html { render :json => @status }
      format.json { render :json => @status }
    end
  end
end
