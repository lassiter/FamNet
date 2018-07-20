class RecipePolicy < ApplicationPolicy

  attr_reader :current_user, :record

  def initialize(current_user, record)
    @current_user = current_user
    @record = record
  end

  def index?
    @current_user
  end

  def search?
    @current_user
  end

  def show?
    current_user.family_members.pluck(:family_id).include?(@record.family_id)
  end

  def create?
    current_user.family_members.pluck(:family_id).include?(@record.family_id)
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
        scoped_member_ids_by_family_member_relationship = FamilyMember.where(family_id: authorized_ids).pluck(:member_id)
        unless authorized_ids.empty?
          records = Recipe.where(member_id: scoped_member_ids_by_family_member_relationship)
          records
        else
          records
        end
      end
    end #resolve
  end



end

