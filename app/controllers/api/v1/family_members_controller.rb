class API::V1::FamilyMembersController < ApplicationController
  # WIP / Todo: Initalize family and first member for signup.
  # def initalize_family_and_first_member
  #   @family = Family.new(family_params)
  #   puts @family.inspect
  #   if @family.save
  #     @member = Member.new(member_params)
  #     if @member.save
  #       render json: {"family": @family, "member": @member}
  #     else
  #       render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
  #     end
  #   else
  #     render json: { errors: @family.errors.full_messages }, status: :unprocessable_entity
  #   end
end
