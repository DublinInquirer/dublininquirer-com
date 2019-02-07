class CategoriesController < ApplicationController
  def show
    @category = params[:id]
    @page = [params[:p].to_i, 1].compact.max

    @articles = Article.in_category(params[:id]).published.by_date.page(@page)

    if !@articles.any?
      raise ActiveRecord::RecordNotFound
    end
  end
end
