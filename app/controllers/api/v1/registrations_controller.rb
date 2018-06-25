class API::V1::RegistrationsController < DeviseTokenAuth::RegistrationsController
  require "pry"

  def create
    super
    create_new_family(params["family"]["family_name"]) if params["family"]["family_name"].present?
  end

private

  def create_new_family(family_name)
    new_family = Family.find_or_create_by(family_name: family_name)
    new_family_member = FamilyMember.find_or_create_by(family_id: new_family.id, member_id: @resource.id)
  end
  def sign_up_params
    params.require(:family).permit(:family_name)
    params.require(:registration).permit(:email, :password, :password_confirmation, :name, :surname, :confirm_success_url, :confirm_error_url)
  end

end
