class API::V1::FamiliesController < ApplicationController
  #before_action :authenticate_user!
  def index
    @families = Family.all
    render json: @families
  end
  def show
    @family = Family.find(params[:id])
  end
  def edit
    @family = Family.find(params[:id])
  end

  # def create
  #   @family = Family.find(params[:id])
    
  #   if @family.save
  #     flash[:notice] = "Family was created."
  #     render json: @family
  #   else
  #     render json: {"error" : "Family was not created."}
  #   end
  # end

end
