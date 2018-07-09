class API::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  require "pry"

  def create
    @newMember = build_member(sign_up_params)
    @newMember.save
    @token = params[:invite_token]
    if @token != nil
      family =  Invite.find_by_token(@token).user_group #find the family attached to the invite
      @newMember.families.push(family) #add this user to the new family as a member
    else
      super
      if params["family"]["family_name"].present? 
        if params["family"]["config"].present?
          create_new_family(params["family"]["family_name"], params["family"]["config"])
        else
          create_new_family(params["family"]["family_name"])  
        end
      end
      binding.pry
      create_new_family_member(params["family"]["family_id"]) if params["family"]["family_id"].present?
      family_id = @resource.family_members.first.family_id
      authorization_processor(family_id, @resource)
    end
  end

private

  def create_new_family_member(family_id)
    new_family_member = FamilyMember.find_or_create_by(family_id: family_id, member_id: @resource.id)
  end

  def create_new_family(family_name, *config)
    new_family = Family.find_or_create_by(family_name: family_name)
    new_family_config = API::V1::FamilyConfig.find_or_create_by(family_id: new_family.id)
    new_family_member = FamilyMember.find_or_create_by(family_id: new_family.id, member_id: @resource.id).update_attributes(user_role: "owner")
    if config.present?
      config = config.first.permit!.to_h if config.first.include?("authorization_enabled")
      @config_record = FamilyConfig.find_by(family_id: new_family.id)
      config.each do | key , value |
        @config_record.update_attributes(authorization_enabled: value) if key.to_s == "authorization_enabled" && value.to_s == "false" # default is true
        puts "authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      end
    end
  end
  def authorization_processor(family_id, resource)
      # if authorization_enabled is false, auto-authorize family_member
      @config_record = FamilyConfig.find_by(family_id: family_id) if @config_record == nil
      if @config_record.authorization_enabled == false
        puts "authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
        record = FamilyMember.find_by(family_id: family_id, member_id: resource.id)
        record.update_attributes(authorized_at: DateTime.now)
        puts "record_id: #{record.id} | authorized_at: #{record.authorized_at}, expecting not nil"
      end
  end
  def sign_up_params
    params.require(:family).permit(:family_name, :family_id, :config => [:authorization_enabled])
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
