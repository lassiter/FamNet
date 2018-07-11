class API::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  require "pry"

  def create
    # this will be filled by branch 3-invites
    super do |resource|
      begin
        if @invite_params.present?
          # this will be filled by branch 3-invites
        elsif @family_params.present? && @family_params[:family_name].present?
          if @family_params[:config].present?
            create_new_family(family_name: @family_params[:family_name], config: @family_params[:config])
          else
            create_new_family(family_name: @family_params[:family_name]) 
          end
        elsif @family_params.present? && @family_params[:family_id].present?
          create_new_family_member(@family_params[:family_id])
        else
          # whoops something went wrong
        end
        @family_id = resource.family_members.first.family_id
      rescue

      ensure
        authorization_processor(@family_id, @resource)
      end
    end
  end # create

private

  def create_new_family_member(family_id)
    new_family_member = FamilyMember.find_or_create_by(family_id: family_id, member_id: @resource.id)
  end

  def create_new_family(family_name:, config: nil)
    new_family = Family.find_or_create_by(family_name: family_name)
    new_family_config = FamilyConfig.find_or_create_by(family_id: new_family.id)
    new_family_member = FamilyMember.find_or_create_by(family_id: new_family.id, member_id: @resource.id).update_attributes(user_role: "owner")
    unless config.nil?
      FamilyConfig.find_by(family_id: new_family.id).update(config)
    end
  end
  
  def authorization_processor(family_id, resource)
      # if authorization_enabled is false, auto-authorize family_member
      if FamilyConfig.find_by(family_id: family_id).authorization_enabled == false
        record = FamilyMember.find_by(family_id: family_id, member_id: resource.id)
        record.update_attributes(authorized_at: DateTime.now)
      end
  end
  def sign_up_params
    @family_params = params.require(:family).permit(:family_name, :family_id, :config => [:authorization_enabled])
    @invite_params = params.permit(:invite_token)
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
