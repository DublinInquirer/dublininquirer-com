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
    issue = Issue.find_by!(issue_date: params[:id])
    position_params[:positions].each_with_index do |article_id, i|
      article = issue.articles.find_by(id: article_id)
      if article.present?
        article.update(position: i)
      end
    end

    render plain: 'noted.'
  end

  private

  def position_params
    params.permit(positions: [])
  end
end
