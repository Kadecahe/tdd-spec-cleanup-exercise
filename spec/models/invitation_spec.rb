require "rails_helper"

RSpec.describe Invitation do
  let(:new_user) { create(:user, email: "rookie@example.com") }

  def build_invitation(team, user)
    Invitation.new(team: team, user: new_user)
  end

  describe "callbacks" do
    describe "after_save" do
      context "with valid data" do
        let(:team) { create(:team, name: "A fine team") }

        it "invites the user" do
          invitation = build_invitation(team, new_user)
          invitation.save
          expect(new_user).to be_invited
        end
      end

      context "with invalid data" do
        it "does not save the invitation" do
          invitation = build_invitation(nil, new_user)
          invitation.save
          expect(invitation).not_to be_valid
          expect(invitation).to be_new_record
        end

        it "does not mark the user as invited" do
          expect(new_user).not_to be_invited
        end
      end
    end
  end

  describe "#event_log_statement" do
    context "when the record is saved" do
      let(:team) { create(:team, name: "A fine team") }

      it "include the name of the team" do
        invitation = build_invitation(team, new_user)
        invitation.save
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("A fine team")
      end

      it "include the email of the invitee" do
        invitation = build_invitation(team, new_user)
        invitation.save
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("rookie@example.com")
      end
    end

    context "when the record is not saved but valid" do
      let(:team) { create(:team, name: "A fine team") }

      it "includes the name of the team" do
        invitation = build_invitation(team, new_user)
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("A fine team")
      end

      it "includes the email of the invitee" do
        invitation = build_invitation(team, new_user)
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("rookie@example.com")
      end

      it "includes the word 'PENDING'" do
        invitation = build_invitation(team, new_user)
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("PENDING")
      end
    end

    context "when the record is not saved and not valid" do
      let(:team) { create(:team, name: "A fine team") }

      it "includes INVALID" do
        invitation = build_invitation(team, nil)
        invitation.user = nil
        log_statement = invitation.event_log_statement
        expect(log_statement).to include("INVALID")
      end
    end
  end
end
