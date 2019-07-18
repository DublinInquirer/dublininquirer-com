class IssuesController < ApplicationController
  def index
    @page = [params[:p].to_i, 1].compact.max
    @issues = Issue.published.order('issue_date desc').page(@page)
  end

  def show
    @issue = Issue.published.find_by(issue_date: params[:id])
    @articles = @issue.articles.by_position
  end
end
