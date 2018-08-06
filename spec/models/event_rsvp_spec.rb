require 'rails_helper'

RSpec.describe EventRsvp, type: :model do
  it_behaves_like 'notifiable'
end
