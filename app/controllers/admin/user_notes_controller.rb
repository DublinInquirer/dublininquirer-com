class Admin::UserNotesController < Admin::ApplicationController
  def create
    @user = User.find(params[:user_id])
    @user_note = @user.user_notes.new(user_note_params)
    @user_note.save
    redirect_to [:admin, @user]
  end

  private

  def user_note_params
    params.require(:user_note).permit(:body)
  end
end
