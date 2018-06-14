class API::V1::TagsController < ApplicationController
  def create
    @tag = Tags.new(tag_params)

    if @tag.save
      render json: @tag
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def destroy
    begin
      @tag = Tag.find(params[:id])
      @tag.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end
  private
      def tag_params
      params.require(:tag).permit(:title, :description, :mature)
    end
end
