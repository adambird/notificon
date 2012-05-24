require 'spec_helper'

class DummyController
  include Notificon::Controller

  def params
    @_params ||= {}
  end
end

describe Controller do
  describe "notificon_tracker" do
    before(:each) do
      @controller = DummyController.new
      @time = random_time
      @controller.stub(:current_time) { @time }
      @controller.stub(:request) { mock("Request", :get? => true) }
    end

    subject { @controller.notificon_tracker }

    context "when id param passed" do
      before(:each) do
        @id = random_string
        @controller.params[Notificon.notification_id_param] = @id
      end

      it "marks the notification as read" do
        Notificon.should_receive(:mark_notification_read).with(@id, @time)
        subject
      end

      context "when item_id param passed" do
        before(:each) do
          @item_id = random_string
          @username = random_string
          @controller.params[Notificon.notification_item_id_param] = @item_id
          @controller.params[Notificon.notification_username_param] = @username
        end
        it "does not attempt to mark notification" do
          Notificon.should_not_receive(:mark_notification_read)
          subject
        end
        it "marks all the notifications for the item read" do
          Notificon.should_receive(:mark_all_read_for_item).with(@username, @item_id, @time)
          subject
        end
      end
    end

    context "when id param not passed" do
      it "does not attempt to mark notification" do
        Notificon.should_not_receive(:mark_notification_read)
        subject
      end
    end

    context "when controller supports current_username and current_item_id" do
      before(:each) do
        @current_username = random_string
        @current_item_id = random_string
        @controller.stub(:current_username) { @current_username }
        @controller.stub(:current_item_id) { @current_item_id }
      end
      it "marks all the notifications for the current_item_id read" do
        Notificon.should_receive(:mark_all_read_for_item).with(@current_username, @current_item_id, @time)
        subject
      end
    end
  end
end
