class PostPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      family_id = user.families.pluck(:id)
      scope.where(family_id: family_id)
    end
  end

  def update?
    user.id == member.id || !record.locked? || user.user_role == (:admin || :owner)
  end
end

