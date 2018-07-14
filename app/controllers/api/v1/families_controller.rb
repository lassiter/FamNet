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
    list_of_family_members = []
    Member.joins(:family_members).where(family_members: { family_id: @family.id }).each do |member|
      serialized_member = DirectoryMemberSerializer.new(member)
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
    @family.inspect
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
  def invite_to
    emails = params[:invite_emails].split(', ')
    emails.each do |email|
      invite = Invite.new(:sender_id => current_user.id, :email => email, family_id => @family.id)
      if invite.save
        if invite.recipient != nil
          InviteMailer.existing_user_invite(invite).deliver
        else
          InviteMailer.new_user_invite(invite, new_user_registration_path(:invite_token => @invite.token))
        end
      end
  end

  private

  def family_params
    # Whitelist of Params
    params.permit(:family_name)
  end

end
