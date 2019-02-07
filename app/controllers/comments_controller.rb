class CommentsController < ApplicationController
  before_action :require_login

  def create
    if !current_user.is_banned?
      @comment = Comment.new(comment_params)
      @comment.user = current_user
      @comment.save!
    end

    respond_to do |format|
      format.js { render 'comments/submitted'}
      format.html { redirect_to("#{ @comment.article.path }#comments") }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:article_id, :content, :nickname)
  end
end
