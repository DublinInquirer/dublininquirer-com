class Admin::ContactMessagesController < Admin::ApplicationController
  def index
    @filter = {}
    @sort = nil

    @contact_messages = ContactMessage.page(params[:p]).per(25)
  end
end
