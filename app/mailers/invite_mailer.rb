class InviteMailer < ApplicationMailer
  default from: 'no-reply-invites@example.com'
 
  def existing_user_invite(invite)
    @invite = invite
    @sender = @invite.sender
    @recipient = @invite.recipient
    host = ENV['HOST'] || "//the-famnet.heroku.com"
    @url  = "#{host}/login"
    mail(to: @recipient, subject: "You've been invited by #{@sender.name} to join the #{@family.family_name} on FamNet.")
  end

  def new_user_invite(invite, path)
    @invite = invite
    @family = @invite.family
    @sender = @invite.sender
    @recipient = @invite.recipient
    host = ENV['HOST'] || "//the-famnet.heroku.com"
    @registration_url = [host,path].join("/")
    @url  = "#{host}/login"
    mail(to: @recipient, subject: "You've been invited by #{@sender.name} to join the #{@family.family_name} on FamNet.")
  end

end
