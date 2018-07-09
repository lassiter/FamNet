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
            create_new_family(@family_params[:family_name], @family_params[:config])
          else
            create_new_family(@family_params[:family_name]) 
          end
        elsif @family_params.present? && @family_params[:family_id].present?
          create_new_family_member(@family_params[:family_id])
        else
          # whoops something went wrong
        end
        @family_id = resource.family_members.first.family_id
        puts "authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      rescue

      ensure
        puts "before authorization_processor,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
        authorization_processor(@family_id, @resource)
        puts "after authorization_processor,authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      end
      puts "end of begin-rescue-end block, authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
    end
    puts "end of create, authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
    binding.pry
  end # create

private

  def create_new_family_member(family_id)
    new_family_member = FamilyMember.find_or_create_by(family_id: family_id, member_id: @resource.id)
  end

  def create_new_family(family_name, *config)
    new_family = Family.find_or_create_by(family_name: family_name)
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
        puts "authorization_enabled: #{@config_record.authorization_enabled}, expecting false"
      end
    end
  end
  
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
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
