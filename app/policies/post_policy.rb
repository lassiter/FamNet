class PostPolicy < ApplicationPolicy
  # class Scope < Scope

  #   def resolve
  #     family_id = current_user.families.pluck(:id)
  #     scope.where(family_id: family_id)
  #   end
  # end

  # def update?
  #   current_user.id == member.id || !record.locked? || (is_moderator?(self.family_id, current_user) || is_admin?(self.family_id, current_user))
  # end
  # def destroy?
  # end


  attr_reader :current_user, :record

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def index?
    @current_user
  end
  def create?
    @current_user
  end

  def update?
    current_user.id == record.member_id || (!record.locked?) && (current_user.id == record.member_id) || (is_moderator?(record.family_id, current_user) || is_admin?(record.family_id, current_user))
  end

  def destroy?
    current_user.id == record.member_id || (is_moderator?(record.family_id, current_user) || is_admin?(record.family_id, current_user))
  end

  class Scope < Scope
    def resolve
      unless current_user == nil
        authorized_ids = current_user.family_members.where.not(authorized_at: nil).pluck(:family_id)
        unless authorized_ids.empty?
          records = Post.where(family_id: authorized_ids)
          records # return the wikis array we've built up
        else
          records # return the wikis array we've built up
        end
      end
    end #resolve

      
  end



end

