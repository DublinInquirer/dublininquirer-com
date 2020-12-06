class TagsController < ApplicationController
  def show
    @tag = Tag.find_by(slug: params[:id])
    @page = [params[:p].to_i, 1].compact.max
    
    if !@tag
      raise ActiveRecord::RecordNotFound
    end

    @articles = Article.in_tag(@tag).published.by_date.page(@page)

    if !@articles.any?
      raise ActiveRecord::RecordNotFound
    end
  end
end