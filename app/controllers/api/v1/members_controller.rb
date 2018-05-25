class API::V1::MembersController < ApplicationController
  def show
    @member = Member.find(params[:id])
    render json: PublicShowMemberSerializer.new(@member)
  end
  def update
    @member = Member.find(params[:id])
    @member.assign_attributes(member_params)

    if @member.save
      render json: PublicShowMemberSerializer.new(@member)
    else
      render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    @member = Member.new(create_member_params)
    if @member.save
      FamilyMember.create(member_id: @member.id, family_id: params[:family][:family_id])
      render json: @member
    else
      render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @member = Member.find(params[:member][:id])
      @member.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end
  private
  def create_member_params
    params.require(:family).permit(:family_id)
    params.require(:member).permit(:user_role, :email, :password, :name, :surname)
  end
  def member_params
    params.require(:member).permit(:id, :image, :image_store, :name, :surname, :nickname, :gender, :bio, :birthday, :instagram, :email, :addresses, :contacts)
  end
end
