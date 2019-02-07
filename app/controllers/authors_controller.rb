class AuthorsController < ApplicationController
  def show
    @author = Author.attempt_to_find_by_slug(params[:id])
    @page = [params[:p].to_i, 1].compact.max
    @articles = @author.articles.published.page(@page)

    if !@author or !@articles.any?
      raise ActiveRecord::RecordNotFound
    end
  end
end
