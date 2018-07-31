require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "Associations" do
    it { should have_many(:notifications) }
    it { should have_many(:comments) }
    it { should have_many(:reactions) }
    it { should belong_to(:family) }
    it { should belong_to(:member) }
  end
  describe "valid" do
    before do
     @member_id = FactoryBot.create(:family_member, authorized_at: DateTime.now).member_id
    end
    it 'FactoryBot factory should be valid' do
      expect(FactoryBot.build(:post, member_id: @member_id) ).to be_valid
    end
    describe ":: location formats" do
      it '[+180.01,+0.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [+180.01,+0.01] ) ).to be_valid
      end
      it '[+0.01,+180.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [+0.01,+180.01] ) ).to be_valid
      end
      it '[+90.01,+1.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[+90.01,+1.01] ) ).to be_valid
      end
      it '[-1.01,-90.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[-1.01,-90.01] ) ).to be_valid
      end
      it '[-180.01,0.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[-180.01,0.01] ) ).to be_valid
      end
      it '[0.01,-180.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[0.01,-180.01] ) ).to be_valid
      end
      it '[0.01,0.01] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [0.01,0.01] ) ).to be_valid
      end
      it '[0,0] is valid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [0,0] ) ).to be_valid
      end
    end
    describe ":: nils" do
      it "all nils should be valid :: location" do
        post = FactoryBot.build(:post, member_id: @member_id, location: nil)
        expect(post).to be_valid
      end
      it "all nils should be valid :: edit" do
        post = FactoryBot.build(:post, member_id: @member_id, edit: nil)
        expect(post).to be_valid
      end
      it "all nils should be valid :: attachment" do
        post = FactoryBot.build(:post, member_id: @member_id, attachment: nil)
        expect(post).to be_valid
      end
    end
  end
  describe "invalid" do
    it "empty news should be invalid" do
      expect(Post.new).to_not be_valid
    end
    describe ":: location formats" do
      before do
        @member_id = FactoryBot.create(:family_member, authorized_at: DateTime.now).member_id
      end
      it '"120.01,1.01" is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:"120.01,1.01" ) ).to_not be_valid
      end
      it '[1111.00,0.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[1111.00,0.00] ) ).to_not be_valid
      end
      it '[0.00,1111.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[0.00,1111.00] ) ).to_not be_valid
      end
      it '[-181.00,-0.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [-181.00,-0.00] ) ).to_not be_valid
      end
      it '[-0.00,-181.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location: [-0.00,-181.00] ) ).to_not be_valid
      end
      it '[180.00,-0.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[180.00,-0.00] ) ).to_not be_valid
      end
      it '[181.00,0.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[181.00,0.00] ) ).to_not be_valid
      end
      it '[0.00,181.00] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[0.00,181.00] ) ).to_not be_valid
      end
      it '[180,180] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[180,180] ) ).to_not be_valid
      end
      it '[180.0,180.0] is invalid' do
        expect(FactoryBot.build(:post, member_id: @member_id, location:[180.0,180.0] ) ).to_not be_valid
      end
    end
    describe ":: nils" do
      it "all nils should be invalid :: body" do
        post = Post.new(body: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: locked" do
        post = Post.new(locked: nil)
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: family_id" do
        post = Post.new(family_id: nil)
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: member_id" do
        post = Post.new(member_id: nil)
        expect(post).to_not be_valid
      end
    end
    describe ":: emptys" do
      it "all nils should be invalid :: body" do
        post = Post.new(body: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: location" do
        post = Post.new(location: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: edit" do
        post = Post.new(edit: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: attachment" do
        post = Post.new(attachment: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: locked" do
        post = Post.new(locked: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: family_id" do
        post = Post.new(family_id: "")
        expect(post).to_not be_valid
      end
      it "all nils should be invalid :: member_id" do
        post = Post.new(member_id: "")
        expect(post).to_not be_valid
      end
    end
  end
end
