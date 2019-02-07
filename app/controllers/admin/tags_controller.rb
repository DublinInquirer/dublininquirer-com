class Admin::TagsController < Admin::ApplicationController
  def index
    @filter = {query: params[:query]}

    @tags = if @filter[:query].present?
      @sort = nil
      Tag.basic_search(@filter[:query]).page(params[:p]).per(25)
    else
      @sort = params[:sort].try(:downcase) || 'name'
      case @sort
      when 'name'
        Tag.by_name.page(params[:p]).per(25)
      else
        raise "Unsupported sort option: #{ @sort }"
      end
    end
  end

  def autocomplete
    render json: Tag.where('slug ILIKE ?', "%#{ params[:q].try('parameterize') }%").limit(5)
  end

  def show
    @tag = Tag.find_by(slug: params[:id])
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to [:admin, @tag]
    else
      render :new
    end
  end

  def hide
    @tag = Tag.find_by(slug: params[:id])
    @tag.displayable = false
    @tag.save!
    redirect_to [:admin, @tag]
  end

  def display
    @tag = Tag.find_by(slug: params[:id])
    @tag.displayable = true
    @tag.save!
    redirect_to [:admin, @tag]
  end

  def destroy

  end

  def tag_params
    params.require(:tag).permit(:name, :displayable)
  end
end
