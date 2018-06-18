class API::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  require "pry"

  def create
    super
    create_new_family(params["family"]["family_name"]) if params["family"]["family_name"].present?
  end

private

  def create_new_family(family_name)
    new_family = Family.where(family_name: family_name).first_or_create
    new_family_member = FamilyMember.where(family_id: new_family.id, member_id: @resource.id).first_or_create
  end
  def sign_up_params
    params.require(:family).permit(:family_name)
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
