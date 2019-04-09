class ContactMessagesController < ApplicationController
  layout 'modal'

  def new
    if params[:regarding].try(:downcase) != 'ebun'
      raise ActiveRecord::RecordNotFound
    end

    @contact_message = ContactMessage.new(regarding: params[:regarding].downcase)
  end

  def create
    @contact_message = ContactMessage.create!(contact_message_params)
    respond_to do |format|
      format.js { render 'contact_messages/submitted'}
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:body, :regarding, :email_address, :full_name)
  end
end
