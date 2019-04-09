class Admin::ContactMessagesController < Admin::ApplicationController
  def index
    @filter = {}
    @sort = nil

    @contact_messages = ContactMessage.order('created_at desc').page(params[:p]).per(25)
  end

  def show
    @contact_message = ContactMessage.find(params[:id])
  end
end
