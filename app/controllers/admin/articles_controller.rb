class Admin::ArticlesController < Admin::ApplicationController
  def index
    @filter = {query: params[:query]}
    @sort = if @filter[:query].present?
      nil
    elsif params[:sort].present?
     params[:sort].try(:downcase)
    else
      'date'
    end

    @articles =  if @filter[:query].present?
      Article.basic_search(@filter[:query]).page(params[:p]).per(25)
    else
      case @sort
      when 'headline'
        Article.by_title.page(params[:p]).per(25)
      when 'date'
        Article.by_date.page(params[:p]).per(25)
      else
        raise "Unsupported sort option: #{ @sort }"
      end
    end
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(meta_params)
    if @article.save
      redirect_to [:admin, @article]
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(meta_params)
      redirect_to([:admin, @article]) && return
    else
      render :edit
    end
  end

  def edit_content
    @article = Article.find(params[:id])
  end

  def update_content
    @article = Article.find(params[:id])
    if @article.update(content_params)
      redirect_to([:admin, @article]) && return
    else
      render :edit_content
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy!

    redirect_to [:admin, :articles]
  end

  private

  def meta_params
    params.require(:article).permit(:title, :excerpt_markdown, :template, :category, :issue_id, :featured_artwork_id, authors_ids: [], tag_ids: [])
  end

  def content_params
    params.require(:article).permit(:content_markdown)
  end
end
