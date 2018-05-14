class API::V1::FamiliesController < ApplicationController
  #before_action :authenticate_user!
  def index
    @families = Family.all
    families_list = []
    @families.each { |family| families_list << IndexFamiliesSerializer.new( family ) }
    render json: { "families" => families_list }
  end

  def show
    @family = Family.find(params[:id])
    render json: {id: @family.id, family_name: @family.family_name}
  end

  def directory
    @family = Family.find(params[:id])
    list_of_family_members = []
    FamilyMember.where(family_id: @family.id).each do |member| # mentor how to make this more efficient
      serialized_member = DirectoryMemberSerializer.new( Member.find( member.member_id ) )
      list_of_family_members << serialized_member
    end
    render json: { "members" => list_of_family_members }
  end

  def update
    @family = Family.find(params[:id])
    if @family.update(family_params)
      render json: @family
    else
      render json: { errors: @family.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create
    @family = Family.new(family_params)
    puts @family.inspect
    if @family.save
      render json: @family
    else
      render json: { errors: @family.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @family = Family.find(params[:id])
      @family.destroy
      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
    end
  end

  private

  def family_params
    # binding.pry
    # Whitelist of Params
    params.permit(:family_name)
  end

end
