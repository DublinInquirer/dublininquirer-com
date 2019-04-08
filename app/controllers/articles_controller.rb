class ArticlesController < ApplicationController
  def show
    slug = internal_slug(params)
    @article = Article.published.by_slug(slug).first

    if !@article
      raise ActiveRecord::RecordNotFound
    end

    @template = @article.template.present? ? @article.template : 'standard'

    # if the article is paywalled, the user doesn't haven't permission, and the browser isn't a bot
    @limited = @article.paywalled? && !browser.bot? && !permission_for_article?(slug)
  end

  def feed
    @articles = Rails.cache.fetch("/articles/feed", expires_in: 1.hour) do
      Article.published.by_date.limit(100)
    end

    respond_to do |format|
      format.xml { render layout: false }
    end
  end

  def search
    @page = [params[:p].to_i, 1].compact.max
    @query = params[:q]
    @articles = Article.published.basic_search(@query).page(@page)
  end

  private

  def internal_slug(params)
    "/#{ params[:year] }/#{ params[:month] }/#{ params[:day] }/#{ params[:slug] }"
  end
end
