class TagsController < ApplicationController
  def show
    @tag = Tag.find_by(slug: params[:id])
    @page = [params[:p].to_i, 1].compact.max

    @articles = Rails.cache.fetch("/tags/#{ @tag.id }/articles/#{ @page }", expires_in: 1.hour) do
      Article.in_tag(@tag).published.by_date.page(@page)
    end

    if !@articles.any?
      raise ActiveRecord::RecordNotFound
    end
  end
end