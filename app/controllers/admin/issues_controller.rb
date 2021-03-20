class Admin::IssuesController < Admin::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:reorder]

  def index
    @issues = Issue.order('issue_date desc').includes(:articles).page(params[:p]).per(25)
  end

  def create
    next_wednesday = (Issue.maximum(:issue_date) || Date.current).next_week.advance(days: 2)
    Issue.create! issue_date: next_wednesday
    redirect_to [:admin, :issues]
  end

  def show
    @issue = Issue.find_or_create_by!(issue_date: params[:id])
    @articles= @issue.articles.by_position
  end

  def publish
    @issue = Issue.find_by(issue_date: params[:id])
    @issue.published = true
    @issue.save!

    redirect_to [:admin, @issue]
  end

  def unpublish
    @issue = Issue.find_by(issue_date: params[:id])
    @issue.published = false
    @issue.save!

    redirect_to [:admin, @issue]
  end

  def reorder
    issue_id = Issue.find_by!(issue_date: params[:id]).id
    
    position_params[:positions]
      .sort_by { |p| p[:position] }
      .each_with_index do |position_param, i|
      a = Article.find_by!(issue_id: issue_id, id: position_param[:id])
      a.update!(position: i)
    end
    
    render plain: 'noted.'
  end

  private

  def position_params
    params.permit(positions: [:id, :position])
  end
end
