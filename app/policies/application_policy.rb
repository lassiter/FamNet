class ApplicationPolicy
  attr_reader :current_user, :record

  def initialize(current_user, record)
    # raise Pundit::NotAuthorizedError, "must be logged in" unless current_user
    @current_user   = current_user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(current_user, record.class)
  end
  
  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user, scope)
      # raise Pundit::NotAuthorizedError, "must be logged in" unless current_user
      @current_user = current_user
      @scope = scope
    end
    def resolve
      scope
    end
  end

  def is_admin?(family_id, member)
    return true if member.family_members.where(user_role: "admin").pluck(:family_id).include?(family_id)
    return false
  end
  def is_moderator?(family_id, member)
    return true if member.family_members.where(user_role: "moderator").pluck(:family_id).include?(family_id)
    return false
  end
end
