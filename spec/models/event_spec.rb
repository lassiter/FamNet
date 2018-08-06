require 'rails_helper'

RSpec.describe Event, type: :model do
  it_behaves_like 'notifiable'
end
