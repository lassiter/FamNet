module Notifiable
  extend ActiveSupport::Concern

  included do

    has_many :notifications, :as => :notifiable

    after_commit :notify_members
  end
  
  def notify_members

    # This is the object storing a string of the polymorphic klass for member lookup. (i.e. if the target is Comment then the attribute will be "commentable".)
    @target_attribute_polymorphic_klass = get_polymorphic_klass(self)

    # The target is the ActiveRecord that is Notifiable after it's been committed to the database.
    # The parent is the Active Record of target and is used to notify the Ancestors.
    @target = self
    @parent = self["#{@target_attribute_polymorphic_klass.downcase}_type"].constantize.where(id:self["#{@target_attribute_polymorphic_klass.downcase}_id"]).first

    # If there are mentions in the target then there will be an iteration over each mention 
    # and if the parent is not mentioned then they will recieve a notification.
    # If there are no mentions then the parent is notified.
    @mentioned_members_id_array = @target.mentioned_members.uniq.pluck(:id)
    if @mentioned_members_id_array.any? # Are there any mentions?
      if @mentioned_members_id_array.include?(@parent.member_id) # Do any mentions include the parent?
        # The parent has been mentioned and is included in the @mentioned_members_id_array.
        @mentioned_members_id_array.each do |member_id|
          Notification.create(notifiable_type: @target.class.to_s, notifiable_id: @target.id, member_id: member_id, mentioned: true)
        end
      else # The parent has not been mentioned and is not in the @mentioned_members_id_array.
        @mentioned_members_id_array.each do |member_id|
          Notification.create(notifiable_type: @target.class.to_s, notifiable_id: @target.id, member_id: member_id, mentioned: true)
        end
        # The parent is notified with `mentioned: false` via DB Default.
        Notification.create(notifiable_type: @target.class.to_s, notifiable_id: @target.id, member_id: @parent.member_id)
      end

    elsif ["Comment", "CommentReply", "Interaction"].any?(@target.class.to_s)
      # This takes the klass from the get_polymorphic_klass method and finds the parent of the Comment, CommentReply, or Interaction.
      Notification.create(notifiable_type: @target.class.to_s, notifiable_id: @target.id, member_id: @parent.member_id)
    end
  end

  # This method gets the polymorphic class attribute from the active record passed to it. 
  def get_polymorphic_klass(target)
    # It cycles through each key looking for a match to `_type` and returns it once found.
    target.attributes.each_key do |i|
     return i.slice(0..-6) if i.match?(/[A-z]+_type/)
    end
  end

end
