class AuthorsController < ApplicationController
  def show
    @author = Author.attempt_to_find_by_slug(params[:id])

    if !@author
      raise ActiveRecord::RecordNotFound
    end

    @page = [params[:p].to_i, 1].compact.max
    @articles = @author.articles.published.by_date.page(@page)
  end
end
