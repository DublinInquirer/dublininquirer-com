class Admin::AuthorsController < Admin::ApplicationController
  def index
    @filter = {query: params[:query]}

    @authors = if @filter[:query].present?
      @sort = nil
      Author.basic_search(@filter[:query]).page(params[:p]).per(25)
    else
      @sort = params[:sort].try(:downcase) || 'name'
      case @sort
      when 'name'
        Author.by_name.page(params[:p]).per(25)
      else
        raise "Unsupported sort option: #{ @sort }"
      end
    end
  end

  def show
    @author = Author.find_by(slug: params[:id])
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)
    if @author.save
      redirect_to [:admin, @author]
    else
      render :new
    end
  end

  def edit
    @author = Author.find_by(slug: params[:id])
  end

  def update
    @author = Author.find_by(slug: params[:id])
    if @author.update(author_params)
      redirect_to [:admin, @author]
    else
      render :edit
    end
  end

  def destroy
    @author = Author.find_by(slug: params[:id])
    if @author.articles.empty? && @author.destroy
      redirect_to [:admin, :authors]
    else
      redirect_to [:admin, @author]
    end
  end

  def author_params
    params.require(:author).permit(:full_name, :bio, :portrait, :remove_portrait)
  end
end
