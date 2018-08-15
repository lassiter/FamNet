require 'rails_helper'

RSpec.shared_examples_for "media" do
  let(:model) { described_class } # the class that includes the concern
  let(:media_subject) { FactoryBot.build(:"#{described_class.to_s.downcase}") }
  context "Basic Model Tests for #{described_class}'s media attachments" do
    describe ':: Uploading' do
      it 'saves the image' do
        media_subject.save!        
        expect(media_subject.media).to_not be_attached
        media_subject.media.attach(io: File.open(Rails.root.to_s + "/spec/fixtures/images/img.jpg"), filename: "img.jpg", content_type: "image/jpg")
        expect(media_subject.media.instance_of?(ActiveStorage::Attached::One)).to be_truthy
        expect(media_subject.media).to be_attached
      end
      it "the attachment record should match #{described_class.to_s.downcase}'s record'" do
        media_subject.save!        
        media_subject.media.attach(io: File.open(Rails.root.to_s + "/spec/fixtures/images/img.jpg"), filename: "img.jpg", content_type: "image/jpg")
        expect(media_subject.media.attachment.record_id).to eq(media_subject.id)
        expect(media_subject.media.attachment.record_type).to eq(media_subject.class.to_s)
        expect(media_subject.media.blob.instance_of?(ActiveStorage::Blob)).to be_truthy
      end
    end
  end
  # context 'Basic Model Tests' do
  #   describe ':: Form' do
  #     it 'expects all fields to be present' do
  #       expect(Notification.new).to_not be_valid
  #     end
  #     it 'expects id to not be nil or blank' do
  #       expect(Notification.new(id: nil)).to_not be_valid
  #       expect(Notification.new(id: "")).to_not be_valid
  #     end
  #     it 'expects notifiable_type to not be nil or blank' do
  #       expect(Notification.new(notifiable_type: nil)).to_not be_valid
  #       expect(Notification.new(notifiable_type: "")).to_not be_valid
  #     end
  #     it 'expects notifiable_id to not be nil or blank' do
  #       expect(Notification.new(notifiable_id: nil)).to_not be_valid
  #       expect(Notification.new(notifiable_id: "")).to_not be_valid
  #     end
  #     it 'expects member_id to not be nil or blank' do
  #       expect(Notification.new(member_id: nil)).to_not be_valid
  #       expect(Notification.new(member_id: "")).to_not be_valid
  #     end
  #     it 'expects mentioned to be false by default' do
  #       notification = Notification.new
  #       expect(notification.mentioned).to eq(false)
  #     end
  #     it 'expects viewed to be false by default' do
  #       notification = Notification.new
  #       expect(notification.viewed).to eq(false)
  #     end
  #   end
  #   describe ':: Function' do
  #     it 'the association works' do
  #       expect {@comparable.notifications}.to_not raise_error
  #     end
  #     it 'creates the notification on save' do
  #       skip "Test should not run if the shared model is Post." if model == Post
  #       Notification.delete_all
  #       expect {@comparable.save}.to change{Notification.count}.from(0).to(1)
  #     end
  #   end
  # end
  # context 'Mention Integration Tests' do
  #   it 'creates two notifications when mentioned' do
  #     skip "Test should not run if the shared model is a Reaction or EventRsvp." if model == Reaction || EventRsvp
  #     name_to_be_mentioned = @mentioned_member.attributes.slice("name", "surname").values.join(" ").insert(0, "@")
  #     @comparable.body.insert(-1, name_to_be_mentioned)
  #     expect{@comparable.save}.to change{Notification.count}.from(0).to(2)
  #   end
  #   it 'expects mention notifications to be marked as true' do
  #     skip "Test should not run if the shared model is a Reaction or EventRsvp." if model == Reaction || EventRsvp
  #     name_to_be_mentioned = @mentioned_member.attributes.slice("name", "surname").values.join(" ").insert(0, "@")
  #     @comparable.body.insert(-1, name_to_be_mentioned)
  #     @comparable.save
  #     example = @comparable
  #     expect(example.notifications.first.mentioned).to eq(true)
  #   end
  # end
  # context 'Specific Cases' do
  #   it "a notification record created on @comparable commit for the @subject object's member on model action" do
  #     skip "Test should not run if the shared model is Post." if model == Post
  #     Notification.delete_all
  #     expect{@comparable.save}.to change{Notification.count}.from(0).to(1)
  #   end
  # end # Specific Cases `context`

end # Test End
