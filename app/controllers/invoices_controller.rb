class InvoicesController < ApplicationController
  layout 'plain'

  def show
    @invoice = current_user.invoices.find_by(number: params[:id])
  end
end
