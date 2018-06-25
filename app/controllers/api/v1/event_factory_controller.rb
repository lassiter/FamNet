class API::V1::EventFactoryController < ApplicationController
  
  def initalize(event_params)
    binding.pry
    @event_params = event_params
    @title = @event_params.title
    @description = @event_params.description
    @member = Member.find(@event_params.member_id)
    @family = Family.find(@event_params.family_id)
  end
  
  def event_creator_rsvp(event_id, member_id)

  end

  def result
    binding.pry
    Event.new({
      title: @title, # string
      description: @description, # text
      member_id: @member.id,
      attachment: nil,
      event_start: nil, 
      event_end: nil, 
      event_allday: false, 
      location: nil, 
      potluck: false, 
      locked: false, 
      family_id: @family.id 
    })
  end
end
