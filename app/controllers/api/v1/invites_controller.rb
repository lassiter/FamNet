class API::V1::InvitesController < ApplicationController

  def new
   @token = params[:invite_token] #<-- pulls the value from the url query string
  end

  def create
    @invite = Invite.new(invite_params)
    @invite.sender_id = current_user.id
    if @invite.save

      #if the user already exists
      if @invite.recipient != nil 

        #send a notification email
        InviteMailer.existing_user_invite(@invite).deliver 

        #Add the user to the user group
        @invite.recipient.families.push(@invite.family)
        recipient = FamilyMember.new(family_id: @invite.family.id, member_id: @invite.recipient.id)
        recipient.save!
      else
        InviteMailer.new_user_invite(@invite, new_user_registration_path(:invite_token => @invite.token)).deliver
      end
    else
      # oh no, creating an new invitation failed
    end
  end
  private
  def invite_params
    params.require(:invite).permit(:family_id, :sender_id, :recipient_id, :email, :invite_token)
  end

end
