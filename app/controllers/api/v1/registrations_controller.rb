class API::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  require "pry"

  def create
<<<<<<< HEAD
=======
<<<<<<< HEAD
    # this will be filled by branch 3-invites
>>>>>>> 93361e917526bc5315910f25b31a2aa8ae309f33
    super do |resource|
      begin
        if @invite_params.present? && @invite_params[:invite_token] != nil
          @token = @invite_params[:invite_token]
          invite = Invite.find_by_token(@token)
          invite.update_attributes(recipient_id: resource.id) # update the recipient_id
          create_new_family_member(invite.family_id) # create new family member based on @token.family
        elsif @family_params.present? && @family_params[:family_name].present?
          if @family_params[:config].present?
            create_new_family(family_name: @family_params[:family_name], config: @family_params[:config])
          else
            create_new_family(family_name: @family_params[:family_name]) 
          end
        elsif @family_params.present? && @family_params[:family_id].present? && !@invite_params.present?
          create_new_family_member(@family_params[:family_id])
        else
          # whoops something went wrong
        end
        @family_id = resource.family_members.first.family_id
      rescue

      ensure
        # if sucessful_registration?(@family_id, @resource)
          authorization_processor(@family_id, @resource)
          # # Void Invite token once sucessfully registered.
          # Invite.find_by_token(@token).update_attributes(accepted_at: DateTime.now, token: nil) if @token.present? && @family_id != nil
        # end
      end
    end
  end # create
<<<<<<< HEAD
=======
=======
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
>>>>>>> e352faff9977980e0871613fc427e68f94339c0c
>>>>>>> 93361e917526bc5315910f25b31a2aa8ae309f33

private

  # def sucessful_registration?(@family_id, @resource)
  #   raise some_failed_registration_rescue unless FamilyMember.exists?(family_id: @family_id, member_id: @resource.id)
  # end

  def create_new_family_member(family_id)
    new_family_member = FamilyMember.find_or_create_by(family_id: family_id, member_id: @resource.id)
  end

  def create_new_family(family_name:, config: nil)
    new_family = Family.find_or_create_by(family_name: family_name)
<<<<<<< HEAD
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
    @invite_params = params.permit(:invite_token)
    # Not required if @invite_params is registering a new user via an invitation.
    @family_params = params.require(:family).permit(:family_name, :family_id, :config => [:authorization_enabled]) unless @invite_params.present?
=======
<<<<<<< HEAD
    puts "new_family.id = #{new_family.id} inside create_new_family method"
    new_family_config = API::V1::FamilyConfig.find_or_create_by(family_id: new_family.id)
    new_family_member = FamilyMember.find_or_create_by(family_id: new_family.id, member_id: @resource.id).update_attributes(user_role: "owner")
    if config.present?
      p config
      config = config.first.permit!.to_h if config.first.include?("authorization_enabled")
      @config_record = FamilyConfig.find_by(family_id: new_family.id)
      config.each do | key , value |
        # issue is here
        @config_record.update_attributes(authorization_enabled: value) if key.to_sym == :authorization_enabled && value.to_sym == :false # default is true
=======
    new_family_config = API::V1::FamilyConfig.find_or_create_by(family_id: new_family.id)
    new_family_member = FamilyMember.find_or_create_by(family_id: new_family.id, member_id: @resource.id).update_attributes(user_role: "owner")
    if config.present?
      config = config.first.permit!.to_h if config.first.include?("authorization_enabled")
      @config_record = FamilyConfig.find_by(family_id: new_family.id)
      config.each do | key , value |
        @config_record.update_attributes(authorization_enabled: value) if key.to_s == "authorization_enabled" && value.to_s == "false" # default is true
>>>>>>> e352faff9977980e0871613fc427e68f94339c0c
        puts "authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      end
    end
  end
<<<<<<< HEAD
  
  def authorization_processor(family_id, resource)
      puts "passed family_id: #{family_id} to authorization_processor"
      puts "inside authorization_processor, before condition ,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      # if authorization_enabled is false, auto-authorize family_member
      if @config_record.authorization_enabled == false
        puts "inside authorization_processor, inside condition ,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
        record = FamilyMember.find_by(family_id: family_id, member_id: resource.id)
        record.update_attributes(authorized_at: DateTime.now)
        puts "inside authorization_processor, inside condition after update,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
        puts "record_id: #{record.id} | authorized_at: #{record.authorized_at}, expecting not nil"
      end
      puts "inside authorization_processor, after condition ,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
  end
  def sign_up_params
    @family_params = params.require(:family).permit(:family_name, :family_id, :config => [:authorization_enabled])
    @invite_params = params.permit(:invite_token)
=======
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
>>>>>>> e352faff9977980e0871613fc427e68f94339c0c
>>>>>>> 93361e917526bc5315910f25b31a2aa8ae309f33
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
